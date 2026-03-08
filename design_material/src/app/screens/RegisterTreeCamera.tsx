import { useState } from "react";
import { useNavigate } from "react-router";
import { Camera, X, CheckCircle2 } from "lucide-react";
import { Button } from "../components/ui/button";

const photoSteps = [
  { id: 1, label: "Tree Front", icon: "🌳", description: "Full view of the tree" },
  { id: 2, label: "Trunk Close-up", icon: "🪵", description: "Bark texture detail" },
  { id: 3, label: "Leaves", icon: "🍃", description: "Foliage and leaf detail" },
];

export default function RegisterTreeCamera() {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(0);
  const [photosTaken, setPhotosTaken] = useState<boolean[]>([false, false, false]);

  const handleTakePhoto = () => {
    const newPhotosTaken = [...photosTaken];
    newPhotosTaken[currentStep] = true;
    setPhotosTaken(newPhotosTaken);

    // Move to next step or finish
    if (currentStep < photoSteps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      // All photos taken, move to location verification
      navigate("/app/register-tree/location");
    }
  };

  const currentPhotoStep = photoSteps[currentStep];

  return (
    <div className="h-screen flex flex-col bg-black">
      {/* Header */}
      <div className="relative z-10 bg-gradient-to-b from-black/80 to-transparent px-6 py-6">
        <div className="flex items-center justify-between mb-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate("/app")}
            className="text-white hover:bg-white/20"
          >
            <X className="w-6 h-6" />
          </Button>
          <h2 className="text-white font-bold">Register Tree</h2>
          <div className="w-10"></div>
        </div>

        {/* Progress Steps */}
        <div className="flex items-center justify-center gap-2">
          {photoSteps.map((step, index) => (
            <div key={step.id} className="flex items-center">
              <div
                className={`w-10 h-10 rounded-full flex items-center justify-center border-2 ${
                  photosTaken[index]
                    ? "bg-[#4CAF6D] border-[#4CAF6D]"
                    : index === currentStep
                    ? "bg-white/20 border-white"
                    : "bg-transparent border-white/40"
                }`}
              >
                {photosTaken[index] ? (
                  <CheckCircle2 className="w-5 h-5 text-white" />
                ) : (
                  <span className="text-sm text-white">{index + 1}</span>
                )}
              </div>
              {index < photoSteps.length - 1 && (
                <div className={`w-8 h-0.5 ${photosTaken[index] ? "bg-[#4CAF6D]" : "bg-white/40"}`}></div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Camera Viewfinder */}
      <div className="flex-1 relative bg-gradient-to-br from-[#2E2E2E] to-[#1A1A1A]">
        {/* Camera guide overlay */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="relative">
            {/* Guide frame */}
            <div className="w-64 h-80 border-4 border-white/60 rounded-3xl relative">
              {/* Corner markers */}
              <div className="absolute -top-1 -left-1 w-8 h-8 border-t-4 border-l-4 border-[#4CAF6D]"></div>
              <div className="absolute -top-1 -right-1 w-8 h-8 border-t-4 border-r-4 border-[#4CAF6D]"></div>
              <div className="absolute -bottom-1 -left-1 w-8 h-8 border-b-4 border-l-4 border-[#4CAF6D]"></div>
              <div className="absolute -bottom-1 -right-1 w-8 h-8 border-b-4 border-r-4 border-[#4CAF6D]"></div>
            </div>

            {/* Instruction overlay */}
            <div className="absolute -bottom-16 left-0 right-0 text-center">
              <div className="text-4xl mb-2">{currentPhotoStep.icon}</div>
              <div className="text-white font-bold text-lg">{currentPhotoStep.label}</div>
              <div className="text-white/70 text-sm">{currentPhotoStep.description}</div>
            </div>
          </div>
        </div>

        {/* Grid lines for alignment */}
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
          <div className="w-full h-full grid grid-cols-3 grid-rows-3 opacity-20">
            {[...Array(9)].map((_, i) => (
              <div key={i} className="border border-white/40"></div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Controls */}
      <div className="relative z-10 bg-gradient-to-t from-black/80 to-transparent px-6 py-8">
        <div className="flex items-center justify-center">
          <Button
            onClick={handleTakePhoto}
            className="h-20 w-20 rounded-full bg-white hover:bg-white/90 text-[#4CAF6D] shadow-2xl flex items-center justify-center"
          >
            <div className="h-16 w-16 rounded-full border-4 border-[#4CAF6D] flex items-center justify-center">
              <Camera className="w-8 h-8" />
            </div>
          </Button>
        </div>

        {/* Photo indicators */}
        <div className="flex justify-center gap-4 mt-6">
          {photoSteps.map((step, index) => (
            <div
              key={step.id}
              className={`px-3 py-1.5 rounded-full text-xs ${
                photosTaken[index]
                  ? "bg-[#4CAF6D] text-white"
                  : "bg-white/20 text-white/60"
              }`}
            >
              {step.label}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
