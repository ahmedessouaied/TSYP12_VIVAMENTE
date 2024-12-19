import axios from 'axios';
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom'; // Import Link from React Router
import SideBar from '../components/sideBar';
import NavBar from '../components/navBar';
import search from '../assets/Focus.png';
import haroun from '../assets/459492009_4703793063179293_1074034971226566309_n.jpg';  
import sg from '../assets/sg.jpg';
import img1 from '../assets/images.jpg'; 
import img2 from '../assets/images (1).jpg';
import img3 from '../assets/images (2).jpg';
import img4 from '../assets/images (3).jpg';
import img5 from '../assets/images (4).jpg';
import img6 from '../assets/iheb.jpg';
export default function Patients() { 
      const images=[sg,img1,img2,img3,img4,img6,img5];
  
  const [patients, setPatients] = useState([]);
  const [nameToSearch, setNameToSearch] = useState('');
  const [error, setError] = useState(null);
  const [showModal, setShowModal] = useState(false); // Modal visibility state
  const [loading, setLoading] = useState(false); // Loading state for form submission
  const [newPatient, setNewPatient] = useState({
    name: '',
    email: '',
    birthDate: '',
    phoneNumber: '',
    medications: [],
    visitations: [],
    imageUrl: '',
  });

  useEffect(() => {
    const fetchPatients = async () => {
      try {
        const response = await axios.get('http://localhost:3000/patients');
        setPatients(response.data);
      } catch (error) {
        setError(error.message);
      }
    };

    fetchPatients();
  }, []);

  const handleAddPatient = async () => {
    setLoading(true);
    try {
      const patientData = {
        ...newPatient,
        birthDate: new Date(newPatient.birthDate).toISOString(),
        imageUrl: newPatient.imageUrl || 'https://example.com/default-image.jpg',
      };

      const response = await axios.post('http://localhost:3000/patients', patientData);
      setPatients([...patients, response.data]); // Add new patient to the list
      setShowModal(false); // Close modal
      setNewPatient({
        name: '',
        email: '',
        birthDate: '',
        phoneNumber: '',
        medications: [],
        visitations: [],
        imageUrl: '',
      });
    } catch (error) {
      console.error('Failed to add patient:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredPatients = patients.filter((patient) =>
    patient.name.toLowerCase().includes(nameToSearch.toLowerCase())
  );

  return (
    <main className="w-full min-h-screen flex justify-start items-stretch">
      <SideBar />
      <div className="flex w-[90%] flex-col justify-start items-center">
        <NavBar text={'PATIENTS'} />
        <div className="w-full flex justify-between items-center mt-10 px-8">
          <div className="w-[60%] py-1 px-2 flex rounded-xl justify-between bg-[#F5F7FA] items-center">
            <input
              className="w-[90%] bg-[#F5F7FA] rounded-xl h-8"
              type="text"
              onChange={(e) => setNameToSearch(e.target.value)}
              value={nameToSearch}
              placeholder="Search for patients..."
            />
            <img src={search} alt="search icon" />
          </div>
          <button
            className="bg-[#34495E] p-3 rounded-lg text-white"
            onClick={() => setShowModal(true)}
          >
            Add Patient
          </button>
        </div>

        {/* Patients List */}
        <div className="w-full flex rounded-xl h-[510px] overflow-y-auto flex-col justify-start items-center gap-4 bg-[#F5F7FA] mt-8">
          {filteredPatients.length > 0 ? (
            filteredPatients.map((patient,index) => (
              <Link
                to={`/patient/${patient.id}`} // Link to the patient's individual page
                key={patient.id}
                className="bg-[#D9D9D9] rounded-xl py-2 px-6 gap-3 w-[80%] flex justify-start items-center hover:bg-gray-300 transition"
              >
                <div className="relative z-0 w-[60px] h-[60px] bg-[#7393B3] flex justify-center items-center rounded-full">
                  <div className="w-[50px] h-[50px] relative z-10 bg-white rounded-full">
                    <img src={images[index]} className=" z-0 relative w-[50px] h-[50px] rounded-full bg-clip-border" />
                  </div>
                </div>
                <span className="text-[#34495E] text-[20px] font-bold">{patient.name}</span>
              </Link>
            ))
          ) : (
            <p>No patients found</p>
          )}
        </div>
      </div>

      {/* Add Patient Modal */}
      {showModal && (
        <div className="fixed top-0 left-0 w-full h-full flex justify-center items-center bg-black bg-opacity-50 z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg w-[400px] flex flex-col">
            <h2 className="text-2xl font-bold mb-4">Add New Patient</h2>
            <input
              type="text"
              placeholder="Name"
              value={newPatient.name}
              onChange={(e) => setNewPatient({ ...newPatient, name: e.target.value })}
              className="w-full p-2 border border-gray-300 rounded-lg mb-4"
            />
            <input
              type="email"
              placeholder="Email"
              value={newPatient.email}
              onChange={(e) => setNewPatient({ ...newPatient, email: e.target.value })}
              className="w-full p-2 border border-gray-300 rounded-lg mb-4"
            />
            <input
              type="date"
              placeholder="Birth Date"
              value={newPatient.birthDate}
              onChange={(e) => setNewPatient({ ...newPatient, birthDate: e.target.value })}
              className="w-full p-2 border border-gray-300 rounded-lg mb-4"
            />
            <input
              type="text"
              placeholder="Phone Number"
              value={newPatient.phoneNumber}
              onChange={(e) => setNewPatient({ ...newPatient, phoneNumber: e.target.value })}
              className="w-full p-2 border border-gray-300 rounded-lg mb-4"
            />
            <input
              type="text"
              placeholder="Image URL"
              value={newPatient.imageUrl}
              onChange={(e) => setNewPatient({ ...newPatient, imageUrl: e.target.value })}
              className="w-full p-2 border border-gray-300 rounded-lg mb-4"
            />
            <div className="flex justify-end gap-2">
              <button
                onClick={() => setShowModal(false)}
                className="bg-gray-400 p-2 rounded-lg text-white"
              >
                Cancel
              </button>
              <button
                onClick={handleAddPatient}
                className="bg-[#34495E] p-2 rounded-lg text-white"
                disabled={loading}
              >
                {loading ? 'Adding...' : 'Add Patient'}
              </button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
