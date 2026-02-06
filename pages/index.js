import { useEffect, useState } from "react";

export default function Home() {

  const [systems, setSystems] = useState([]);

  async function load() {
    const res = await fetch("/api/list");
    const data = await res.json();
    setSystems(data);
  }

  async function sendCommand(system, command) {
    await fetch("/api/setCommand", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ system, command })
    });
  }

  useEffect(() => {
    load();
    setInterval(load, 5000);
  }, []);

  return (
    <div style={{padding:20}}>
      <h2>Mining Control</h2>

      {systems.map(s => (
        <div key={s.id} style={{marginBottom:10}}>
          <b>{s.id}</b><br/>
          VPN: {String(s.vpn)}<br/>
          Mining: {String(s.mining)}<br/>

          <button onClick={() => sendCommand(s.id,"start")}>
            START
          </button>

          <button onClick={() => sendCommand(s.id,"stop")}>
            STOP
          </button>
        </div>
      ))}
    </div>
  )
}
