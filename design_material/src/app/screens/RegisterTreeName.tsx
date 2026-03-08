import { useState } from "react";
import { useNavigate } from "react-router";
import { TreePine, X, Sparkles } from "lucide-react";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import { motion } from "motion/react";

const suggestedNames = [
  "Grand Oak",
  "Park Maple",
  "Guardian Willow",
  "Street Elm",
  "Noble Pine",
  "Heritage Cedar",
];

export default function RegisterTreeName() {
  const navigate = useNavigate();
  const [treeName, setTreeName] = useState("");
  const [showSuccess, setShowSuccess] = useState(false);

  const handleRegister = (e: React.FormEvent) => {
    e.preventDefault();
    setShowSuccess(true);
    
    // Animate success then redirect
    setTimeout(() => {
      navigate("/app/tree/1"); // Navigate to the newly created tree profile
    }, 2500);
  };

  if (showSuccess) {
    return (
      <div className="h-screen flex flex-col items-center justify-center bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] px-6">
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ type: "spring", duration: 0.8 }}
          className="mb-8"
        >
          <div className="w-32 h-32 rounded-full bg-white flex items-center justify-center shadow-2xl">
            <TreePine className="w-16 h-16 text-[#4CAF6D]" />
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="text-center"
        >
          <h1 className="text-4xl font-bold text-white mb-3">Tree Registered! 🌳</h1>
          <p className="text-white/90 text-lg mb-6">
            {treeName || "Your tree"} is now protected
          </p>

          {/* Coin Reward Animation */}
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: [0, 1.2, 1] }}
            transition={{ delay: 0.6, duration: 0.5 }}
            className="bg-white/20 backdrop-blur-lg rounded-2xl p-6"
          >
            <div className="text-5xl mb-2">🪙</div>
            <div className="text-2xl font-bold text-white">+50 KOK Coins</div>
          </motion.div>
        </motion.div>

        {/* Confetti-like sparkles */}
        {[...Array(8)].map((_, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, scale: 0, x: 0, y: 0 }}
            animate={{
              opacity: [0, 1, 0],
              scale: [0, 1, 0.5],
              x: Math.cos((i * Math.PI * 2) / 8) * 150,
              y: Math.sin((i * Math.PI * 2) / 8) * 150,
            }}
            transition={{ delay: 0.8 + i * 0.1, duration: 1 }}
            className="absolute top-1/2 left-1/2"
          >
            <Sparkles className="w-6 h-6 text-white" />
          </motion.div>
        ))}
      </div>
    );
  }

  return (
    <div className="h-screen flex flex-col bg-gradient-to-br from-[#F5F5F5] via-[#E8F5E9] to-[#C8E6C9]">
      {/* Header */}
      <div className="px-6 py-6">
        <div className="flex items-center justify-between mb-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate("/app")}
            className="text-[#2E2E2E] hover:bg-white/50"
          >
            <X className="w-6 h-6" />
          </Button>
          <h2 className="text-[#2E2E2E] font-bold">Name Your Tree</h2>
          <div className="w-10"></div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col px-6 py-8">
        {/* Tree Preview */}
        <div className="flex justify-center mb-8">
          <div className="relative">
            <div className="w-32 h-32 rounded-full bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] flex items-center justify-center shadow-lg">
              <TreePine className="w-16 h-16 text-white" />
            </div>
            <div className="absolute -bottom-2 -right-2 w-12 h-12 rounded-full bg-white flex items-center justify-center shadow-md">
              <span className="text-2xl">🌳</span>
            </div>
          </div>
        </div>

        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-[#2E2E2E] mb-2">
            Give Your Tree a Name
          </h1>
          <p className="text-[#717171]">
            Make it memorable and unique
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleRegister} className="space-y-6">
          <div>
            <Input
              type="text"
              placeholder="e.g., Grand Oak, Park Maple"
              value={treeName}
              onChange={(e) => setTreeName(e.target.value)}
              className="h-14 text-lg rounded-2xl bg-white border-2 border-[#E8E8E8] focus:border-[#4CAF6D]"
              required
            />
          </div>

          {/* Suggested Names */}
          <div>
            <p className="text-sm text-[#717171] mb-3">Suggestions:</p>
            <div className="flex flex-wrap gap-2">
              {suggestedNames.map((name) => (
                <button
                  key={name}
                  type="button"
                  onClick={() => setTreeName(name)}
                  className="px-4 py-2 rounded-full bg-white border border-[#E8E8E8] text-[#2E2E2E] text-sm hover:border-[#4CAF6D] hover:bg-[#4CAF6D]/5 transition-colors"
                >
                  {name}
                </button>
              ))}
            </div>
          </div>

          <div className="flex-1"></div>

          <Button
            type="submit"
            className="w-full h-14 bg-gradient-to-r from-[#4CAF6D] to-[#6BCB77] hover:from-[#2E7D32] hover:to-[#4CAF6D] text-white rounded-2xl text-lg shadow-lg"
          >
            Register Tree
          </Button>

          <Button
            type="button"
            variant="ghost"
            onClick={() => setTreeName("")}
            className="w-full h-12 text-[#717171] hover:text-[#2E2E2E]"
          >
            Skip - I'll name it later
          </Button>
        </form>
      </div>
    </div>
  );
}
