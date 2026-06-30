export function StatusMessage({ title, detail }: { title: string; detail?: string }) {
  return (
    <section className="notice">
      <strong>{title}</strong>
      {detail ? <p>{detail}</p> : null}
    </section>
  );
}
