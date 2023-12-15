// ConnectModal.js
import React from 'react'
import { useConnect } from '@starknet-react/core'
import { Dialog } from '@headlessui/react'
import '../../assets/styles/ConnectModal.css'

export default function ConnectModal({ isOpen, onClose }) {
  const { connect, connectors } = useConnect()

  return (
    <Dialog open={isOpen} onClose={onClose} className='dialog-overlay'>
      <Dialog.Panel className='dialog-panel'>
        <Dialog.Title className='dialog-title'>Connect Wallet</Dialog.Title>
        <Dialog.Description className='dialog-description'>
          {connectors.map((connector) => (
            <button
              key={connector.id}
              onClick={() => {
                connect({ connector })
                onClose()
              }}
              disabled={!connector.available()}
              className='connect-button'
            >
              Connect {connector.name}
            </button>
          ))}
        </Dialog.Description>
      </Dialog.Panel>
    </Dialog>
  )
}
