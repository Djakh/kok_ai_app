import { Link } from "react-router";
import { TreePine, Camera, MapPin, Trophy, Users, Leaf } from "lucide-react";
import { Card } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Cell } from "recharts";

const impactData = [
  { month: "Jan", trees: 12 },
  { month: "Feb", trees: 18 },
  { month: "Mar", trees: 25 },
  { month: "Apr", trees: 32 },
  { month: "May", trees: 45 },
  { month: "Jun", trees: 58 },
];

const leaderboardData = [
  { name: "Sarah Chen", trees: 156, avatar: "🌟" },
  { name: "Mike Johnson", trees: 142, avatar: "🌲" },
  { name: "You", trees: 58, avatar: "🌳" },
];

export default function Dashboard() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#C49A6C] via-[#F5F5F5] to-[#6BCB77]/20">
      {/* Header */}
      <div className="bg-gradient-to-r from-[#9C7A57] to-[#C49A6C] px-6 py-8 rounded-b-3xl">
        <h1 className="text-3xl font-bold text-white mb-2">Welcome Back!</h1>
        <p className="text-white/90">Let's protect more trees today</p>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* Impact Summary Card */}
        <Card className="p-6 bg-gradient-to-br from-white to-[#F5F5F5] border-0 shadow-lg">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-bold text-[#2E2E2E]">Your Impact</h2>
            <div className="w-10 h-10 rounded-full bg-[#4CAF6D]/10 flex items-center justify-center">
              <TreePine className="w-5 h-5 text-[#4CAF6D]" />
            </div>
          </div>
          
          <div className="grid grid-cols-3 gap-4 mb-6">
            <div className="text-center">
              <div className="text-3xl font-bold text-[#4CAF6D]">58</div>
              <div className="text-sm text-[#717171]">Trees</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-[#9C7A57]">2.4t</div>
              <div className="text-sm text-[#717171]">CO₂ Saved</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-[#6BCB77]">1,240</div>
              <div className="text-sm text-[#717171]">KOK Coins</div>
            </div>
          </div>

          {/* Chart */}
          <div className="h-40 -mx-2">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={impactData}>
                <XAxis dataKey="month" tick={{ fill: "#717171", fontSize: 12 }} />
                <YAxis tick={{ fill: "#717171", fontSize: 12 }} />
                <Bar dataKey="trees" radius={[8, 8, 0, 0]}>
                  {impactData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={index % 2 === 0 ? "#4CAF6D" : "#9C7A57"} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-4">
          <Link to="/app/register-tree/camera">
            <Button className="w-full h-32 bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] hover:from-[#2E7D32] hover:to-[#4CAF6D] text-white border-0 rounded-2xl flex flex-col items-center justify-center gap-2 shadow-lg">
              <Camera className="w-8 h-8" />
              <span className="text-lg">Register Tree</span>
            </Button>
          </Link>
          
          <Link to="/app/map">
            <Button className="w-full h-32 bg-gradient-to-br from-[#9C7A57] to-[#C49A6C] hover:from-[#7A5D42] hover:to-[#9C7A57] text-white border-0 rounded-2xl flex flex-col items-center justify-center gap-2 shadow-lg">
              <MapPin className="w-8 h-8" />
              <span className="text-lg">Open Map</span>
            </Button>
          </Link>
        </div>

        {/* Today's Challenge */}
        <Card className="p-5 bg-gradient-to-r from-[#6BCB77]/20 to-[#4CAF6D]/20 border-[#4CAF6D]/30 border-2">
          <div className="flex items-start gap-3">
            <div className="w-12 h-12 rounded-full bg-[#4CAF6D] flex items-center justify-center flex-shrink-0">
              <Trophy className="w-6 h-6 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="font-bold text-[#2E2E2E] mb-1">Today's Challenge</h3>
              <p className="text-[#2E2E2E]/80 text-sm mb-2">Register 2 new trees today</p>
              <div className="flex items-center gap-2">
                <div className="flex-1 h-2 bg-white/50 rounded-full overflow-hidden">
                  <div className="h-full w-0 bg-[#4CAF6D] rounded-full"></div>
                </div>
                <span className="text-xs text-[#717171]">0/2</span>
              </div>
            </div>
          </div>
        </Card>

        {/* Leaderboard Preview */}
        <Card className="p-5 bg-white border-0 shadow-md">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-[#2E2E2E]">Top Guardians</h3>
            <Trophy className="w-5 h-5 text-[#9C7A57]" />
          </div>
          <div className="space-y-3">
            {leaderboardData.map((user, index) => (
              <div key={index} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="text-2xl">{user.avatar}</div>
                  <div>
                    <div className="font-medium text-[#2E2E2E]">{user.name}</div>
                    <div className="text-sm text-[#717171]">{user.trees} trees</div>
                  </div>
                </div>
                <div className="text-xl font-bold text-[#4CAF6D]">#{index + 1}</div>
              </div>
            ))}
          </div>
        </Card>

        {/* Community Highlights */}
        <Card className="p-5 bg-white border-0 shadow-md">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-[#2E2E2E]">Community</h3>
            <Users className="w-5 h-5 text-[#4CAF6D]" />
          </div>
          <div className="space-y-4">
            <div className="flex gap-3">
              <div className="w-10 h-10 rounded-full bg-[#6BCB77]/20 flex items-center justify-center flex-shrink-0">
                <Leaf className="w-5 h-5 text-[#4CAF6D]" />
              </div>
              <div className="flex-1">
                <p className="text-sm text-[#2E2E2E]">
                  <span className="font-medium">Maria Garcia</span> registered a new tree in Central Park 🌳
                </p>
                <p className="text-xs text-[#717171] mt-1">2 hours ago</p>
              </div>
            </div>
            <div className="flex gap-3">
              <div className="w-10 h-10 rounded-full bg-[#9C7A57]/20 flex items-center justify-center flex-shrink-0">
                <TreePine className="w-5 h-5 text-[#9C7A57]" />
              </div>
              <div className="flex-1">
                <p className="text-sm text-[#2E2E2E]">
                  <span className="font-medium">John Smith</span> completed the Weekly Challenge!
                </p>
                <p className="text-xs text-[#717171] mt-1">5 hours ago</p>
              </div>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
