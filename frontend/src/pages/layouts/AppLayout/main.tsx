import { Outlet } from 'react-router-dom';

export function AppLayout() {
  return (
    <main>
      {/* A global header or navigation could go here */}
      <Outlet />
      {/* A global footer could go here */}
    </main>
  );
}
