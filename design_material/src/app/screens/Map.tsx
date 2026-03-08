import { useState } from "react";
import { Link } from "react-router";
import { Camera, Navigation, Search, Filter } from "lucide-react";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";

// Mock tree data
const trees = [
  { id: 1, lat: 40.7829, lng: -73.9654, status: "healthy", name: "Central Oak" },
  { id: 2, lat: 40.7749, lng: -73.9558, status: "needs-attention", name: "Park Maple" },
  { id: 3, lat: 40.7589, lng: -73.9851, status: "healthy", name: "Grand Willow" },
  { id: 4, lat: 40.7614, lng: -73.9776, status: "healthy", name: "Street Birch" },
  { id: 5, lat: 40.7580, lng: -73.9855, status: "unknown", name: "Unknown Tree" },
];

export default function Map() {
  const [searchQuery, setSearchQuery] = useState("");

  return (
    <div className="h-screen flex flex-col bg-[#F5F5F5]">
      {/* Header */}
      <div className="bg-white px-6 py-4 shadow-sm z-10">
        <div className="flex items-center gap-2 mb-3">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#717171]" />
            <Input
              type="text"
              placeholder="Search trees..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 bg-[#F5F5F5] border-0 h-11 rounded-xl"
            />
          </div>
          <Button
            variant="outline"
            size="icon"
            className="h-11 w-11 rounded-xl border-[#E8E8E8]"
          >
            <Filter className="w-5 h-5 text-[#717171]" />
          </Button>
        </div>
        
        <div className="flex items-center gap-2 text-sm text-[#717171]">
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded-full bg-[#4CAF6D]"></div>
            <span>Healthy</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded-full bg-[#9C7A57]"></div>
            <span>Needs Attention</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded-full bg-[#A0A0A0]"></div>
            <span>Unknown</span>
          </div>
        </div>
      </div>

      {/* Map Area */}
      <div className="flex-1 relative bg-gradient-to-br from-[#E8F5E9] to-[#F5F5DC]">
        {/* Mock map with tree markers */}
        <div className="absolute inset-0 overflow-hidden">
          {/* Grid pattern for map feel */}
          <div className="absolute inset-0" style={{
            backgroundImage: `
              linear-gradient(rgba(0,0,0,0.03) 1px, transparent 1px),
              linear-gradient(90deg, rgba(0,0,0,0.03) 1px, transparent 1px)
            `,
            backgroundSize: '40px 40px'
          }}></div>

          {/* Tree markers positioned pseudo-randomly */}
          {trees.map((tree, index) => {
            const statusColors = {
              "healthy": "#4CAF6D",
              "needs-attention": "#9C7A57",
              "unknown": "#A0A0A0"
            };
            
            // Position markers in a visually pleasing layout
            const positions = [
              { top: "25%", left: "30%" },
              { top: "40%", left: "65%" },
              { top: "55%", left: "40%" },
              { top: "35%", left: "75%" },
              { top: "70%", left: "55%" },
            ];
            
            const position = positions[index] || positions[0];
            
            return (
              <Link
                key={tree.id}
                to={`/app/tree/${tree.id}`}
                className="absolute -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
                style={position}
              >
                {/* Tree marker */}
                <div className="relative">
                  <svg width="48" height="56" viewBox="0 0 48 56" className="drop-shadow-lg transition-transform group-hover:scale-110">
                    {/* Tree trunk */}
                    <rect x="20" y="32" width="8" height="16" fill="#8B4513" rx="2" />
                    {/* Tree canopy - three leaf circles */}
                    <circle cx="24" cy="24" r="12" fill={statusColors[tree.status as keyof typeof statusColors]} />
                    <circle cx="16" cy="28" r="9" fill={statusColors[tree.status as keyof typeof statusColors]} opacity="0.9" />
                    <circle cx="32" cy="28" r="9" fill={statusColors[tree.status as keyof typeof statusColors]} opacity="0.9" />
                  </svg>
                  
                  {/* Pulse animation */}
                  <div 
                    className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-12 h-12 rounded-full animate-ping opacity-20"
                    style={{ backgroundColor: statusColors[tree.status as keyof typeof statusColors] }}
                  ></div>
                </div>
              </Link>
            );
          })}

          {/* User location indicator */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
            <div className="relative">
              <div className="w-6 h-6 rounded-full bg-blue-500 border-4 border-white shadow-lg"></div>
              <div className="absolute inset-0 w-6 h-6 rounded-full bg-blue-400 animate-ping"></div>
            </div>
          </div>
        </div>

        {/* Recenter button */}
        <Button
          size="icon"
          className="absolute top-4 right-4 h-12 w-12 rounded-full bg-white hover:bg-[#F5F5F5] text-[#4CAF6D] shadow-lg z-10"
        >
          <Navigation className="w-5 h-5" />
        </Button>

        {/* Stats card */}
        <div className="absolute bottom-4 left-4 right-4 bg-white/95 backdrop-blur rounded-2xl p-4 shadow-lg">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-sm text-[#717171]">Trees Nearby</div>
              <div className="text-2xl font-bold text-[#4CAF6D]">{trees.length}</div>
            </div>
            <div className="text-right">
              <div className="text-sm text-[#717171]">In Your Area</div>
              <div className="text-2xl font-bold text-[#9C7A57]">45</div>
            </div>
          </div>
        </div>
      </div>

      {/* Floating Register Tree Button */}
      <Link to="/app/register-tree/camera" className="fixed bottom-24 right-6 z-20">
        <Button
          size="icon"
          className="h-16 w-16 rounded-full bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] hover:from-[#2E7D32] hover:to-[#4CAF6D] text-white shadow-2xl"
        >
          <Camera className="w-7 h-7" />
        </Button>
      </Link>
    </div>
  );
}
