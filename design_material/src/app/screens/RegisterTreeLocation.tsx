import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { Navigation, X } from "lucide-react";
import { Button } from "../components/ui/button";
import { Progress } from "../components/ui/progress";

export default function RegisterTreeLocation() {
  const navigate = useNavigate();
  const [progress, setProgress] = useState(0);
  const [isVerifying, setIsVerifying] = useState(false);

  useEffect(() => {
    if (isVerifying && progress < 100) {
      const timer = setTimeout(() => {
        setProgress((prev) => Math.min(prev + 5, 100));
      }, 100);
      return () => clearTimeout(timer);
    } else if (progress === 100) {
      setTimeout(() => {
        navigate("/app/register-tree/name");
      }, 500);
    }
  }, [progress, isVerifying, navigate]);

  const handleStartVerification = () => {
    setIsVerifying(true);
    setProgress(5);
  };

  return (
    <div className="h-screen flex flex-col bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77]">
      {/* Header */}
      <div className="px-6 py-6">
        <div className="flex items-center justify-between mb-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate("/app")}
            className="text-white hover:bg-white/20"
          >
            <X className="w-6 h-6" />
          </Button>
          <h2 className="text-white font-bold">Verify Location</h2>
          <div className="w-10"></div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col items-center justify-center px-6">
        {/* Location Icon with Animation */}
        <div className="relative mb-12">
          {/* Outer pulse rings */}
          <div className="absolute inset-0 w-48 h-48 rounded-full bg-white/20 animate-ping"></div>
          <div className="absolute inset-0 w-48 h-48 rounded-full bg-white/10 animate-pulse"></div>
          
          {/* Center circle */}
          <div className="relative w-48 h-48 rounded-full bg-white/30 backdrop-blur-lg flex items-center justify-center">
            <div className="w-32 h-32 rounded-full bg-white flex items-center justify-center">
              <Navigation className="w-16 h-16 text-[#4CAF6D]" />
            </div>
          </div>

          {/* Progress circle overlay */}
          {isVerifying && (
            <svg className="absolute inset-0 w-48 h-48 -rotate-90">
              <circle
                cx="96"
                cy="96"
                r="88"
                fill="none"
                stroke="white"
                strokeWidth="8"
                strokeDasharray={`${(progress / 100) * 553} 553`}
                className="transition-all duration-300"
              />
            </svg>
          )}
        </div>

        {/* Instructions */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-white mb-3">
            {isVerifying ? "Verifying Location..." : "Hold Your Phone Close"}
          </h1>
          <p className="text-white/90 text-lg max-w-md">
            {isVerifying
              ? "Keep your phone close to the tree"
              : "Touch your phone to the tree to confirm its location"}
          </p>
        </div>

        {/* Progress Bar */}
        {isVerifying && (
          <div className="w-full max-w-sm mb-8">
            <Progress value={progress} className="h-3 bg-white/30" />
            <div className="text-center text-white mt-2 font-bold">{progress}%</div>
          </div>
        )}

        {/* Start Button */}
        {!isVerifying && (
          <Button
            onClick={handleStartVerification}
            className="h-16 px-12 bg-white hover:bg-white/90 text-[#4CAF6D] rounded-2xl text-xl font-bold shadow-2xl"
          >
            Start Verification
          </Button>
        )}

        {/* Tip */}
        <div className="absolute bottom-8 left-6 right-6">
          <div className="bg-white/20 backdrop-blur-lg rounded-2xl p-4">
            <p className="text-white/90 text-sm text-center">
              💡 Make sure you're standing within 1 meter of the tree for accurate GPS verification
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
