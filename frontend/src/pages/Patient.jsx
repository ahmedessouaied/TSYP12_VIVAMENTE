import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import SideBar from '../components/sideBar';
import NavBar from '../components/navBar';
import haroun from '../assets/459492009_4703793063179293_1074034971226566309_n.jpg'; 
import iheb from "../assets/iheb.jpg";
import sg from '../assets/sg.jpg';


export default function Patient() {
    const { id } = useParams();
    const [patient, setPatient] = useState(null);
    const [error, setError] = useState(null);
    const [showModal, setShowModal] = useState(false);
    const [notes, setNotes] = useState('');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const fetchPatientDetails = async () => {
            try {
                const response = await axios.get(`http://localhost:3000/patients/${id}`);
                setPatient(response.data);
            } catch (error) {
                setError('Failed to fetch patient details');
            }
        };
        fetchPatientDetails();
    }, [id]);

    // Open Video Call in a New Tab
    const openVideoCall = () => {
        window.open('https://embs-video-stream-xyjc.vercel.app', '_blank');
    };

    const handleAddVisitation = async () => {
        setLoading(true);
        try {
            const data = { notes };
            await axios.patch(`http://localhost:3000/patients/addVisitation/${id}`, data);
            const response = await axios.get(`http://localhost:3000/patients/${id}`);
            setPatient(response.data);
            setShowModal(false);
            setNotes('');
        } catch (error) {
            console.error('Failed to add visitation:', error);
        } finally {
            setLoading(false);
        }
    };

    if (error) return <p>{error}</p>;
    if (!patient) return <p>Loading patient details...</p>;

    return (
        <main className="w-full min-h-screen flex justify-start items-stretch">
            <SideBar />
            <div className="flex w-[90%] flex-col justify-start items-center">
                <NavBar text={'PATIENT'} />
                <div className="w-full flex justify-end items-center mr-8 gap-2 mt-5">
                    <button
                        className="bg-[#34495E] p-3 rounded-lg text-white"
                        onClick={() => setShowModal(true)}
                    >
                        Add Visitation
                    </button>
                    <button
                        className="bg-green-600 p-3 rounded-lg text-white"
                        onClick={openVideoCall} // Open video call in a new tab
                    >
                        Video Call
                    </button>
                </div>

                {/* Patient Info Section */}
                <div className="flex justify-center items-center mt-16 ml-6 p-4 w-full">
                    <div className="relative z-0 w-[140px] h-[140px] bg-[#7393B3] flex justify-center items-center rounded-full">
                        <div className="w-[120px] h-[120px] relative z-10 bg-white rounded-full">
                            <img src={iheb} className="rounded-full w-[120px] h-[120px] bg-clip-border" alt="Patient" />
                        </div>
                    </div>
                    <div className="w-full ml-6 grid grid-cols-3">
                        <InfoField label="Name" value={patient.name} />
                        <InfoField label="Email" value={patient.email} />
                        <InfoField label="Date of Birth" value={formatDate(patient.birthDate)} />
                        <InfoField label="Phone Number" value={patient.phoneNumber} />
                        <InfoField label="Last visited" value={formatDate(patient.updatedAt)} />
                        <InfoField label="Started Visiting" value={formatDate(patient.createdAt)} />
                    </div>
                </div>

                {/* Visitations */}
                <div className="flex flex-col w-full justify-start items-start">
                    <span className="text-[20px] font-bold text-[#717171]">Notes</span>
                    <div className="w-full rounded-xl h-44 overflow-y-auto p-4 bg-[#F5F7FA]">
                        {patient.visitations.map((e, index) => (
                            <div key={index} className="mb-4">
                                <div className="font-extrabold">
                                    * {new Date(e.date).toLocaleString()}
                                </div>
                                <div>{e.notes.notes}</div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Add Visitation Modal */}
                {showModal && (
                    <div className="fixed top-0 left-0 w-full h-full flex justify-center items-center bg-black bg-opacity-50 z-50">
                        <div className="bg-white p-6 rounded-lg shadow-lg w-[400px] flex flex-col">
                            <h2 className="text-2xl font-bold mb-4">Add Visitation</h2>
                            <textarea
                                rows="4"
                                placeholder="Write notes here..."
                                value={notes}
                                onChange={(e) => setNotes(e.target.value)}
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
                                    onClick={handleAddVisitation}
                                    className="bg-[#34495E] p-2 rounded-lg text-white"
                                    disabled={loading}
                                >
                                    {loading ? 'Saving...' : 'Add'}
                                </button>
                            </div>
                        </div>
                    </div>
                )}<div className='flex flex-col w-full justify-start items-start'> 
                <span className='text-[20px] font-bold text-[#717171]'>Current Medication:</span>  
                 <div className='w-full rounded-xl p-4 bg-[#F5F7FA] flex flex-col justify-start items-start '>  

                     {patient.medications.length===0 ?<div>Not currently on Meds!</div> :patient.medications.map((e)=>(<><div className='font-extrabold'>*{e.name}</div><div>{e.dosage}/{e.frequency}</div></>))}
                 </div> 
                 </div>
            </div>
        </main>
    );
}

// Helper Component for Reusability
const InfoField = ({ label, value }) => (
    <div className="flex flex-col">
        <span className="text-[20px] font-bold text-[#34495E]">{label}:</span>
        <span className="text-[18px] font-bold text-[#717171]">{value}</span>
    </div>
);

// Date Formatting Helper
const formatDate = (date) => new Date(date).toLocaleString().slice(0, 9);
