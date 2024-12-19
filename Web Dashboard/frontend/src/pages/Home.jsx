import axios from 'axios'; 
import { Link } from 'react-router-dom';
import img1 from '../assets/images.jpg'; 
import img2 from '../assets/images (1).jpg';
import img3 from '../assets/images (2).jpg';
import img4 from '../assets/images (3).jpg';
import img5 from '../assets/images (4).jpg';


import React, { useState, useEffect } from 'react'; // Add useState and useEffect
import SideBar from '../components/sideBar'; 
import NavBar from '../components/navBar'; 
import heart from '../assets/group_13466526 1.png'; 
import ppl from '../assets/heart_6868759 1.png'; 
import cal from '../assets/calendar_2886665 (1) 1.png'; 
import haroun from '../assets/459492009_4703793063179293_1074034971226566309_n.jpg'

export default function Home() {  
    const images=[img1,img2,img3,img4,img5];
    const [patients, setPatients] = useState([]);  // State to hold patients 
    const [patientsLen, setPatientsLen] = useState();  // State to hold patients
    const [patientOnMed,setPatientOnMed]= useState();
    const [error, setError] = useState(null);       // State to manage any errors
  
    useEffect(() => {
      // Define the API URL
      const fetchPatients = async () => {
        try {
          const response = await axios.get('http://localhost:3000/patients');
          console.log(response) 
          setPatientsLen(response.data.length) 
          setPatientOnMed(response.data.filter((e) => e.medications.length !== 0).length);
          // Sort patients by updatedAt (ascending order: older dates first)
          const sortedPatients = response.data.sort((a, b) => new Date(b.updatedAt)-new Date(a.updatedAt)  ).slice(0,6);
          
          setPatients(sortedPatients);   // Update the state with the sorted data
        } catch (error) {
          setError(error.message); // Update the error state
        }
      };
  
      // Call the fetch function
      fetchPatients();
    }, []); // Empty dependency array means this runs only once when the component mounts
  
    if (error) {
      return <p>Error: {error}</p>;
    }

    return ( 
      <main className="w-full min-h-screen flex justify-start items-stretch">  
        <SideBar/>
        <div className='flex w-[90%] flex-col justify-start items-center'>  
          <NavBar text={'DASHBOARD'}/> 
          <div className='flex justify-around items-center w-full mt-16'> 
            <div className='flex justify-around items-center w-[30%] rounded-xl shadow-lg py-8 bg-[#F5F7FA]'> 
              <img width={75} src={heart}/> 
              <div className='flex flex-col justify-center items-center'> 
                <span className='text-[#717171] text-[20px]'>Patients</span>  
                <span className='text-[#34495E] text-[22px]'>{patientsLen}</span> 
              </div>
            </div> 
            <div className='flex justify-around items-center w-[30%] rounded-xl shadow-lg py-8 bg-[#F5F7FA]'> 
              <img width={75} src={cal}/> 
              <div className='flex flex-col justify-center items-center'> 
                <span className='text-[#717171] text-[20px]'>Appointments</span>  
                <span className='text-[#34495E] text-[22px]'>3</span> 
              </div>
            </div> 
            <div className='flex justify-around items-center w-[30%] rounded-xl shadow-lg py-8 bg-[#F5F7FA]'> 
              <img width={75} src={ppl}/> 
              <div className='flex flex-col justify-center items-center'> 
                <span className='text-[#717171] text-[20px]'>Patients On Medicine</span>  
                <span className='text-[#34495E] text-[22px]'>{patientOnMed}</span> 
              </div>
            </div>
          </div> 
          <div className='w-full px-8 mt-16 flex flex-col justify-start items-start'> 
            <span className='text-[#717171] text-[25px] '>Last Patients Checked:</span> 
            <div className='w-full overflow-y-auto h-80  bg-[#F5F7FA] rounded-lg'> 
              
              {
                patients.map((patient,index) => ( 
                  <>
                  <Link to={`/patient/${patient.id}`} key={patient.id} className='py-2 w-full flex justify-start items-center gap-7'> 
                    <div className="relative  z-0 w-[60px] h-[60px] bg-[#7393B3] flex justify-center items-center rounded-full "> 
                                <div className="w-[50px] h-[50px] relative z-10 bg-white rounded-full"> 
                                  <img src={images[index]} className='rounded-full bg-clip-border'/>
                                </div> 
                              </div>  
                    <span className='text-[#34495E] text-[22px] font-bold'>{patient.name}</span> {/* Adjust according to your data structure */} 
                    <span>Last visited: {new Date(patient.updatedAt).toLocaleString()}</span>
                  </Link> 
                  <div className='w-full h-[1px] bg-[#34495E]'></div> </>
                ))
  }
            </div>
          </div>
        </div>
      </main>
    );
  }

 

