import SideBar from './components/sideBar'; 
import NavBar from './components/navBar';
function App() {
  

  return (
    <main className="w-full min-h-screen flex  justify-start items-stretch">  
      <SideBar/>
      <div className='flex w-[90%] flex-col justify-start items-center'>  
        <NavBar/>
      </div>

      
    </main>
  )
}

export default App
