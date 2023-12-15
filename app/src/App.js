// App.js
import React from 'react'
import './App.css'
import Dice from './components/Dice'
import ConnectWallet from './components/ConnectWallet'
import { StarknetProvider } from './components/StarknetProvider'

function App() {
  const handleRoll = (diceValue) => {
    console.log(`Rolled: ${diceValue}`)
  }

  return (
    <StarknetProvider>
      <div className='App'>
        <ConnectWallet />
        <Dice onRoll={handleRoll} />
      </div>
    </StarknetProvider>
  )
}

export default App
