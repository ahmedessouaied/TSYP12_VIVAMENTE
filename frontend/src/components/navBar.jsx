import React from 'react';

export default function NavBar({ text }) {  // Destructure `text` from props
  return (
    <div className='flex justify-between items-center rounded-xl bg-[#F5F7FA] py-5 px-3 w-[97%] mt-5'>
        <span className='w-[30%] text-[#34495E] font-extrabold text-[20px]'>{text}</span> 
        <div className='w-[30%] flex justify-center items-center gap-5'> 
            <span className='text-[#717171] '>Home</span> 
            <span className='text-[#717171] '>Alerts</span> 
            <span className='text-[#717171] '>Help</span> 
            <span className='text-[#717171] '>Settings</span>
        </div>
    </div>
  );
}
