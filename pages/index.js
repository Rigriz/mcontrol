import { useEffect, useState } from 'react'

export default function Home() {

  const [systems, setSystems] = useState([])

  async function load() {
    const res = await fetch('/api/list')
    const data = await res.json()
    setSystems(data)
  }

  useEffect(() => {
    load()
    const i = setInterval(load, 5000)
    return () => clearInterval(i)
  }, [])

  async function sendCommand(system, cmd) {
    await fetch('/api/set-command', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ system, command: cmd })
    })
  }

  return (
    <div style={{ padding: 30 }}>
      <h1>Worker Dashboard</h1>

      {systems.map(s => (
        <div key={s.system}
             style={{ border:'1px solid #ccc', margin:10, padding:10 }}>

          <h3>{s.system}</h3>

          <p>Status: {s.running ? "Running" : "Stopped"}</p>
          <p>CPU: {s.cpu}%</p>
          <p>VPN: {s.vpn ? "OK" : "OFF"}</p>

          <button onClick={()=>sendCommand(s.system,'start')}>
            START
          </button>

          <button onClick={()=>sendCommand(s.system,'stop')}>
            STOP
          </button>

        </div>
      ))}
    </div>
  )
}
