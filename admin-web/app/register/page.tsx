import { AuthForm } from '../../components/AuthForm';

export default function RegisterPage() {
  return (
    <main className="auth-shell">
      <AuthForm mode="register" />
    </main>
  );
}
