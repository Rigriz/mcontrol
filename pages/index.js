import { useEffect, useState } from 'react'

export default function Home() {

  const [systems, setSystems] = useState([])

  async function load() {
    try {
      const res = await fetch('/api/list')
      const data = await res.json()

      if (Array.isArray(data)) {
        setSystems(data)
      } else {
        setSystems([])
      }
    } catch (err) {
      console.log("Load error:", err)
      setSystems([])
    }
  }

  useEffect(() => {
    load()
    const i = setInterval(load, 5000)
    return () => clearInterval(i)
  }, [])

  return (
    <div style={{ padding: 30 }}>
      <h1>Dashboard</h1>

      {systems.length === 0 && (
        <p>No systems connected yet.</p>
      )}

      {systems.map(s => (
        <div key={s.id}
             style={{ border:'1px solid #ccc', padding:10, margin:10 }}>

          <h3>{s.id}</h3>
          <p>Running: {String(s.running)}</p>
          <p>CPU: {s.cpu}</p>
          <p>VPN: {String(s.vpn)}</p>

        </div>
      ))}
    </div>
  )
}
