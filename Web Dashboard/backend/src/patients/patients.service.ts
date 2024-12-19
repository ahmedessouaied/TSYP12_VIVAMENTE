import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { JsonObject } from '@prisma/client/runtime/library';
import { DatabaseService } from 'src/database/database.service';
@Injectable()
export class PatientsService { 
  constructor(private readonly databaseServices:DatabaseService){}
  create(createPatientDto: Prisma.PatientCreateInput) {
    return this.databaseServices.patient.create({data:createPatientDto});
  } 

  async addVisitation(id: string, notes: string) {
    // Fetch the existing patient and their visitations
    const patient = await this.databaseServices.patient.findUnique({
      where: { id },
      select: { visitations: true }, // Only fetch the visitations field
    });
  
    if (!patient) {
      throw new Error('Patient not found');
    }
  
    // Parse visitations or initialize as an empty array
    const currentVisitations = Array.isArray(patient.visitations)
      ? patient.visitations
      : [];
  
    if (!Array.isArray(currentVisitations)) {
      throw new Error('Visitations is not an array');
    }
  
    // Create the new visitation object
    const newVisitation = {
      date: new Date().toISOString(), // Current date
      notes, // Pass the notes as a JSON object
    };
  
    // Prepend the new visitation
    const updatedVisitations = [newVisitation, ...currentVisitations];
  
    // Update the visitations field
    return this.databaseServices.patient.update({
      where: { id },
      data: {
        visitations: updatedVisitations, 
        updatedAt: new Date(), // Explicitly update `updatedAt` to current time

      },
    });
  }
  
  

  async  findAll() {
    return this.databaseServices.patient.findMany();
  }

  async  findOne(id: string) {
    return this.databaseServices.patient.findUnique({where: {id,}});
  }

  async  update(id: string, updatePatientDto: Prisma.PatientUpdateInput) {
    return this.databaseServices.patient.update({where:{id,},data:updatePatientDto,} )
  }

  async  remove(id: string) {
    return this.databaseServices.patient.delete({where:{id,}});
  }
}
