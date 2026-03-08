import { useState } from "react";
import { useNavigate, Link } from "react-router";
import { TreePine, Mail, Lock } from "lucide-react";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";

export default function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Mock login - navigate to dashboard
    navigate("/app");
  };

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-br from-[#9C7A57] via-[#C49A6C] to-[#4CAF6D] max-w-[480px] mx-auto">
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
        {/* Logo */}
        <div className="mb-8 text-center">
          <div className="inline-flex items-center justify-center w-24 h-24 rounded-full bg-white/20 backdrop-blur-sm mb-4">
            <TreePine className="w-12 h-12 text-white" />
          </div>
          <h1 className="text-4xl font-bold text-white mb-2">KOK.AI</h1>
          <p className="text-white/90 text-lg">Protect Urban Trees</p>
        </div>

        {/* Login Form */}
        <form onSubmit={handleLogin} className="w-full max-w-sm space-y-4">
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#717171]" />
            <Input
              type="email"
              placeholder="Email or phone"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="pl-11 bg-white/95 backdrop-blur border-0 h-14 rounded-2xl"
              required
            />
          </div>

          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#717171]" />
            <Input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="pl-11 bg-white/95 backdrop-blur border-0 h-14 rounded-2xl"
              required
            />
          </div>

          <Button
            type="submit"
            className="w-full h-14 bg-[#4CAF6D] hover:bg-[#2E7D32] text-white rounded-2xl text-lg"
          >
            Login
          </Button>

          <div className="text-center pt-4">
            <Link
              to="/register"
              className="text-white hover:text-white/80 underline"
            >
              Don't have an account? Register
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
