import { useState } from "react";
import { useNavigate, Link } from "react-router";
import { TreePine, User, Mail, Lock, Camera } from "lucide-react";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";

export default function Register() {
  const navigate = useNavigate();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const handleRegister = (e: React.FormEvent) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      alert("Passwords do not match");
      return;
    }
    // Mock registration - navigate to dashboard
    navigate("/app");
  };

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-br from-[#4CAF6D] via-[#6BCB77] to-[#9C7A57] max-w-[480px] mx-auto">
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
        {/* Logo */}
        <div className="mb-8 text-center">
          <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-white/20 backdrop-blur-sm mb-3">
            <TreePine className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-white mb-1">Create Account</h1>
          <p className="text-white/90">Join the tree guardian community</p>
        </div>

        {/* Register Form */}
        <form onSubmit={handleRegister} className="w-full max-w-sm space-y-4">
          {/* Optional Avatar */}
          <div className="flex justify-center mb-2">
            <button
              type="button"
              className="w-20 h-20 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center hover:bg-white/30 transition-colors"
            >
              <Camera className="w-8 h-8 text-white" />
            </button>
          </div>

          <div className="relative">
            <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#717171]" />
            <Input
              type="text"
              placeholder="Name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="pl-11 bg-white/95 backdrop-blur border-0 h-14 rounded-2xl"
              required
            />
          </div>

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

          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#717171]" />
            <Input
              type="password"
              placeholder="Confirm password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="pl-11 bg-white/95 backdrop-blur border-0 h-14 rounded-2xl"
              required
            />
          </div>

          <Button
            type="submit"
            className="w-full h-14 bg-white text-[#4CAF6D] hover:bg-white/90 rounded-2xl text-lg"
          >
            Create Account
          </Button>

          <div className="text-center pt-2">
            <Link to="/" className="text-white hover:text-white/80 underline">
              Already have an account? Login
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
