import { Link } from 'react-router-dom';
import haroun from '../assets/459492009_4703793063179293_1074034971226566309_n.jpg'; 
import Logout from '../assets/Group 240.png'; 


export default function sideBar() {
  return (
    <div className="w-[23%] mt-5 h-[700px] ml-5 rounded-xl p-4 bg-[#34495E] flex flex-col justify-between items-center">   
        <div className="w-full flex flex-col justify-center items-center">
          <div className="relative  z-0 w-[140px] h-[140px] bg-[#7393B3] flex justify-center items-center rounded-full "> 
            <div className="w-[120px] h-[120px] relative z-10 bg-white rounded-full"> 
              <img src={haroun} className='rounded-full bg-clip-border'/>
            </div> 
          </div>  
          <span className='text-[#89939E] text-[20px] font-extrabold'>Dr. Haroun Mabrouk</span> 
        </div> 
        <div className='w-full flex flex-col justify-center items-center gap-5'> 
          <Link to='/' className='w-[70%] bg-[#ABBED1] text-center font-bold text-[18px] rounded-lg py-2 text-[#263238]'>Dashboard</Link>
          <div className='w-[70%] bg-[#ABBED1] text-center font-bold text-[18px] rounded-lg py-2 text-[#263238]'>Schedule</div>
          <Link to='/patients' className='w-[70%] bg-[#ABBED1] text-center font-bold text-[18px] rounded-lg py-2 text-[#263238]'>Patients</Link> 
          <div className='w-[70%] bg-[#ABBED1] text-center font-bold text-[18px] rounded-lg py-2 text-[#263238]'>Messages</div>
          <div className='w-[70%] bg-[#ABBED1] text-center font-bold text-[18px] rounded-lg py-2 text-[#263238]'>Medicine</div>
  
        </div>  
        <div className='w-full flex justify-center items-center'>
          <img className='w-28 ' src={Logout}/> 
        </div>
      </div>
  )
}
