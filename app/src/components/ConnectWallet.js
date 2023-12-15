import React, { useState } from 'react'
import '../assets/styles/ConnectWalletButton.css'

import { useAccount, useDisconnect } from '@starknet-react/core'

import ConnectModal from './wallet/connect-modal'

const ConnectWallet = () => {
  const { address } = useAccount()
  const { disconnect } = useDisconnect()
  let [isModalOpen, setIsModalOpen] = useState(false)

  const handClick = () => {
    if (address) {
      disconnect()
    } else {
      setIsModalOpen(true)
    }
  }

  const buttonClass = `connect-wallet-button ${address ? 'connected' : ''}`

  return (
    <>
      <button className={buttonClass} onClick={handClick}>
        {address
          ? `${address.slice(0, 6)}...${address.slice(-4)}`
          : 'Connect Wallet'}
      </button>
      <ConnectModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </>
  )
}

export default ConnectWallet
