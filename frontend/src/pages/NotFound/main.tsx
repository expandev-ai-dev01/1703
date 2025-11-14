import { Link } from 'react-router-dom';

function NotFoundPage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-6xl font-bold">404</h1>
      <p className="text-xl mt-4">Page Not Found</p>
      <Link to="/" className="mt-6 text-blue-500 hover:underline">
        Go back to Home
      </Link>
    </div>
  );
}

export default NotFoundPage;
