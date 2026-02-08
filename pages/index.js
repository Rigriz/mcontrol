import { useState } from 'react'

export default function Dashboard() {

  const [status, setStatus] = useState("stop")

  async function sendCommand(cmd) {
    await fetch('/api/set-command', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: "YOUR_UUID",
        command: cmd
      })
    })

    setStatus(cmd)
  }

  return (
    <div>
      <h2>Mining Control</h2>

      <p>Status: {status}</p>

      <button onClick={() => sendCommand("start")}>
        Start Mining
      </button>

      <button onClick={() => sendCommand("stop")}>
        Stop Mining
      </button>
    </div>
  )
}
