import { useEffect, useState } from 'react'

export default function Home() {

  const [systems, setSystems] = useState([])

  async function loadData() {
    const res = await fetch('/api/list')
    const data = await res.json()
    setSystems(data)
  }

  async function sendCommand(id, command) {
    await fetch('/api/setcommand', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, command })
    })
    loadData()
  }

  function isOnline(lastSeen) {
    if (!lastSeen) return false
    const diff = (Date.now() - new Date(lastSeen)) / 1000
    return diff < 120   // 2 minutes
  }

  useEffect(() => {
    loadData()
    const t = setInterval(loadData, 5000)
    return () => clearInterval(t)
  }, [])

  return (
    <div style={{ padding: 20, fontFamily: 'Arial' }}>
      <h2>Mining Control Dashboard</h2>

      <table border="1" cellPadding="10" style={{ borderCollapse: "collapse", width: "100%" }}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Status</th>
            <th>Mining</th>
            <th>CPU</th>
            <th>VPN</th>
            <th>Last Seen</th>
            <th>Control</th>
          </tr>
        </thead>

        <tbody>
          {systems.map(s => {

            const online = isOnline(s.last_seen)

            return (
              <tr key={s.id}>
                <td>{s.id}</td>

                <td>
                  <span style={{
                    color: online ? "green" : "red",
                    fontWeight: "bold"
                  }}>
                    {online ? "ONLINE" : "OFFLINE"}
                  </span>
                </td>

                <td>{s.mining ? "Running" : "Stopped"}</td>

                <td>{s.cpu || 0}%</td>

                <td>{s.vpn ? "OK" : "OFF"}</td>

                <td>
                  {s.last_seen
                    ? new Date(s.last_seen).toLocaleString()
                    : "-"}
                </td>

                <td>
                  <button onClick={() => sendCommand(s.id, "start")}>
                    Start
                  </button>

                  <button
                    onClick={() => sendCommand(s.id, "stop")}
                    style={{ marginLeft: 10 }}
                  >
                    Stop
                  </button>
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}
