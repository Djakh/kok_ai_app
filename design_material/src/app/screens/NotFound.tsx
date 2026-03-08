import { useNavigate } from "react-router";
import { TreePine } from "lucide-react";
import { Button } from "../components/ui/button";

export default function NotFound() {
  const navigate = useNavigate();

  return (
    <div className="h-screen flex flex-col items-center justify-center bg-gradient-to-br from-[#F5F5F5] to-[#E8F5E9] px-6">
      <div className="text-center">
        <div className="inline-flex items-center justify-center w-32 h-32 rounded-full bg-gradient-to-br from-[#9C7A57] to-[#C49A6C] mb-6">
          <TreePine className="w-16 h-16 text-white" />
        </div>
        
        <h1 className="text-6xl font-bold text-[#2E2E2E] mb-4">404</h1>
        <h2 className="text-2xl font-bold text-[#2E2E2E] mb-2">Tree Not Found</h2>
        <p className="text-[#717171] mb-8 max-w-md">
          Looks like this tree has wandered off the path. Let's get you back to exploring!
        </p>

        <Button
          onClick={() => navigate("/app")}
          className="h-14 px-8 bg-gradient-to-r from-[#4CAF6D] to-[#6BCB77] hover:from-[#2E7D32] hover:to-[#4CAF6D] text-white rounded-2xl text-lg"
        >
          Back to Dashboard
        </Button>
      </div>
    </div>
  );
}
