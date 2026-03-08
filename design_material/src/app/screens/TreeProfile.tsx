import { useNavigate, useParams } from "react-router";
import {
  ArrowLeft,
  MapPin,
  User,
  Camera,
  AlertCircle,
  Navigation,
  Heart,
  Share2,
  Droplet,
  Sun,
  Wind,
} from "lucide-react";
import { Button } from "../components/ui/button";
import { Card } from "../components/ui/card";
import { Badge } from "../components/ui/badge";

export default function TreeProfile() {
  const navigate = useNavigate();
  const { id } = useParams();

  // Mock tree data
  const tree = {
    id,
    name: "Grand Oak",
    species: "Quercus robur",
    guardian: "Sarah Chen",
    location: "Central Park, New York",
    coordinates: "40.7829° N, 73.9654° W",
    health: "Healthy",
    registered: "March 5, 2026",
    lastUpdate: "2 days ago",
    height: "15m",
    age: "~45 years",
  };

  const timeline = [
    {
      date: "March 7, 2026",
      user: "You",
      action: "Viewed tree profile",
      icon: "👁️",
    },
    {
      date: "March 5, 2026",
      user: "Sarah Chen",
      action: "Updated tree photo",
      icon: "📸",
    },
    {
      date: "March 1, 2026",
      user: "Mike Johnson",
      action: "Reported healthy status",
      icon: "✅",
    },
    {
      date: "February 28, 2026",
      user: "Sarah Chen",
      action: "Registered this tree",
      icon: "🌳",
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#F5F5F5] to-[#E8F5E9]">
      {/* Header Image */}
      <div className="relative h-72 bg-gradient-to-br from-[#9C7A57] to-[#4CAF6D]">
        {/* Placeholder for tree image */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-8xl">🌳</div>
        </div>

        {/* Back Button */}
        <Button
          variant="ghost"
          size="icon"
          onClick={() => navigate(-1)}
          className="absolute top-6 left-6 bg-black/20 hover:bg-black/40 text-white backdrop-blur-sm"
        >
          <ArrowLeft className="w-5 h-5" />
        </Button>

        {/* Action Buttons */}
        <div className="absolute top-6 right-6 flex gap-2">
          <Button
            variant="ghost"
            size="icon"
            className="bg-black/20 hover:bg-black/40 text-white backdrop-blur-sm"
          >
            <Heart className="w-5 h-5" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="bg-black/20 hover:bg-black/40 text-white backdrop-blur-sm"
          >
            <Share2 className="w-5 h-5" />
          </Button>
        </div>

        {/* Health Badge */}
        <div className="absolute bottom-4 left-6">
          <Badge className="bg-[#4CAF6D] text-white px-4 py-2 text-base">
            {tree.health}
          </Badge>
        </div>
      </div>

      {/* Content */}
      <div className="px-6 py-6 space-y-6">
        {/* Tree Info Card */}
        <Card className="p-6 bg-white border-0 shadow-md">
          <h1 className="text-3xl font-bold text-[#2E2E2E] mb-2">{tree.name}</h1>
          <p className="text-[#717171] italic mb-4">{tree.species}</p>

          <div className="space-y-3">
            <div className="flex items-center gap-3 text-[#2E2E2E]">
              <User className="w-5 h-5 text-[#4CAF6D]" />
              <div>
                <div className="text-sm text-[#717171]">Guardian</div>
                <div className="font-medium">{tree.guardian}</div>
              </div>
            </div>

            <div className="flex items-center gap-3 text-[#2E2E2E]">
              <MapPin className="w-5 h-5 text-[#9C7A57]" />
              <div>
                <div className="text-sm text-[#717171]">Location</div>
                <div className="font-medium">{tree.location}</div>
                <div className="text-xs text-[#717171]">{tree.coordinates}</div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 mt-6 pt-6 border-t border-[#E8E8E8]">
            <div>
              <div className="text-sm text-[#717171]">Registered</div>
              <div className="font-medium text-[#2E2E2E]">{tree.registered}</div>
            </div>
            <div>
              <div className="text-sm text-[#717171]">Last Update</div>
              <div className="font-medium text-[#2E2E2E]">{tree.lastUpdate}</div>
            </div>
          </div>
        </Card>

        {/* Environmental Data */}
        <Card className="p-6 bg-gradient-to-br from-[#E8F5E9] to-white border-0 shadow-md">
          <h2 className="font-bold text-[#2E2E2E] mb-4">Environmental Data</h2>
          <div className="grid grid-cols-3 gap-4">
            <div className="text-center">
              <div className="w-12 h-12 rounded-full bg-[#4CAF6D]/20 flex items-center justify-center mx-auto mb-2">
                <Sun className="w-6 h-6 text-[#4CAF6D]" />
              </div>
              <div className="text-xs text-[#717171]">Height</div>
              <div className="font-bold text-[#2E2E2E]">{tree.height}</div>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 rounded-full bg-[#6BCB77]/20 flex items-center justify-center mx-auto mb-2">
                <Droplet className="w-6 h-6 text-[#6BCB77]" />
              </div>
              <div className="text-xs text-[#717171]">Age</div>
              <div className="font-bold text-[#2E2E2E]">{tree.age}</div>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 rounded-full bg-[#9C7A57]/20 flex items-center justify-center mx-auto mb-2">
                <Wind className="w-6 h-6 text-[#9C7A57]" />
              </div>
              <div className="text-xs text-[#717171]">CO₂/year</div>
              <div className="font-bold text-[#2E2E2E]">48kg</div>
            </div>
          </div>
        </Card>

        {/* Action Buttons */}
        <div className="grid grid-cols-3 gap-3">
          <Button
            variant="outline"
            className="flex flex-col items-center h-auto py-4 border-[#E8E8E8] hover:border-[#4CAF6D] hover:bg-[#4CAF6D]/5"
          >
            <Camera className="w-6 h-6 text-[#4CAF6D] mb-1" />
            <span className="text-xs">Update Photo</span>
          </Button>

          <Button
            variant="outline"
            className="flex flex-col items-center h-auto py-4 border-[#E8E8E8] hover:border-[#9C7A57] hover:bg-[#9C7A57]/5"
          >
            <AlertCircle className="w-6 h-6 text-[#9C7A57] mb-1" />
            <span className="text-xs">Report Issue</span>
          </Button>

          <Button
            variant="outline"
            className="flex flex-col items-center h-auto py-4 border-[#E8E8E8] hover:border-[#6BCB77] hover:bg-[#6BCB77]/5"
          >
            <Navigation className="w-6 h-6 text-[#6BCB77] mb-1" />
            <span className="text-xs">Visit Tree</span>
          </Button>
        </div>

        {/* Activity Timeline */}
        <Card className="p-6 bg-white border-0 shadow-md">
          <h2 className="font-bold text-[#2E2E2E] mb-4">Activity Timeline</h2>
          <div className="space-y-4">
            {timeline.map((item, index) => (
              <div key={index} className="flex gap-3">
                <div className="flex-shrink-0 w-10 h-10 rounded-full bg-[#F5F5F5] flex items-center justify-center text-xl">
                  {item.icon}
                </div>
                <div className="flex-1">
                  <div className="flex items-baseline gap-2">
                    <span className="font-medium text-[#2E2E2E]">{item.user}</span>
                    <span className="text-sm text-[#717171]">{item.action}</span>
                  </div>
                  <div className="text-xs text-[#717171] mt-0.5">{item.date}</div>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
}
