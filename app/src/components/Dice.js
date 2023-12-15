import React, { useState } from 'react'
import '../assets/styles/Dice.css'

const Dice = ({ onRoll }) => {
  const [diceValue, setDiceValue] = useState(1)
  const [isRolling, setIsRolling] = useState(false)

  const rollDice = () => {
    setIsRolling(true)
    let rollCount = 0
    const maxRolls = 10 // The number of times the dice will "roll" before stopping
    const intervalTime = 100 // Milliseconds between each "roll"

    // Randomly change the dice value every interval to simulate rolling
    const diceRollInterval = setInterval(() => {
      rollCount++
      setDiceValue(Math.floor(Math.random() * 8) + 1)

      if (rollCount >= maxRolls) {
        clearInterval(diceRollInterval)
        setIsRolling(false)
        // Set the final dice value
        const finalValue = Math.floor(Math.random() * 8) + 1
        setDiceValue(finalValue)
        onRoll(finalValue)
      }
    }, intervalTime)
  }

  const diceImageUrl = `/images/dices/d${diceValue}.png`
  const diceClass = isRolling ? 'dice-image animate' : 'dice-image'

  return (
    <div className='dice-container'>
      <img
        src={diceImageUrl}
        alt={`Dice ${diceValue}`}
        className={diceClass}
        onClick={rollDice}
        style={{ cursor: isRolling ? 'default' : 'pointer' }}
      />
    </div>
  )
}

export default Dice
