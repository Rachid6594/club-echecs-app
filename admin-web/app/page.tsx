const members = ['Rachid', 'Awa', 'Moussa', 'Fatou'];
const disputes = ['Resultat conteste table 2', 'Clock timeout a verifier'];

export default function AdminDashboard() {
  return (
    <main className="shell">
      <aside className="sidebar">
        <h1>Club Echecs Admin</h1>
        <nav>
          <a>Dashboard</a>
          <a>Membres</a>
          <a>Tournois</a>
          <a>Litiges</a>
          <a>Badges</a>
          <a>Audit logs</a>
        </nav>
      </aside>
      <section className="content">
        <section className="topbar">
          <div>
            <p className="eyebrow">Login admin</p>
            <h2>Dashboard general</h2>
          </div>
          <button>Nouvelle competition</button>
        </section>

        <section className="metrics">
          <article><span>Membres actifs</span><strong>42</strong></article>
          <article><span>Matchs en cours</span><strong>6</strong></article>
          <article><span>Tournois ouverts</span><strong>2</strong></article>
          <article><span>Litiges</span><strong>2</strong></article>
        </section>

        <section className="grid">
          <article className="panel">
            <h3>Gestion des membres</h3>
            {members.map((member) => <p key={member}>{member} · joueur actif</p>)}
          </article>

          <article className="panel">
            <h3>Creation tournoi</h3>
            <label>Nom du tournoi<input defaultValue="Coupe du Club" /></label>
            <label>Format<select defaultValue="single"><option value="single">Elimination directe</option><option>Round-robin</option><option>Groupes + finale</option></select></label>
            <button>Tirage aleatoire</button>
          </article>

          <article className="panel wide">
            <h3>Tableau visuel elimination directe</h3>
            <div className="bracket">
              <span>Quart 1</span><span>Demi 1</span><span>Finale</span><span>Champion</span>
              <span>Quart 2</span><span>Demi 2</span><span>Finaliste</span><span>Bonus +50</span>
            </div>
          </article>

          <article className="panel">
            <h3>Classement general</h3>
            <ol><li>Rachid · 120 pts</li><li>Awa · 98 pts</li><li>Moussa · 74 pts</li></ol>
          </article>

          <article className="panel">
            <h3>Litiges et corrections</h3>
            {disputes.map((item) => <p key={item}>{item}</p>)}
            <button>Correction resultat</button>
          </article>

          <article className="panel">
            <h3>Gestion badges/rangs</h3>
            <p>Novice I · Premiere victoire · Champion</p>
          </article>

          <article className="panel">
            <h3>Audit logs</h3>
            <p>admin · correction_resultat · maintenant</p>
          </article>
        </section>
      </section>
    </main>
  );
}

