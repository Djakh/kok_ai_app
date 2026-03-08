import { Camera, Settings, LogOut, Trophy, TreePine, Coins } from "lucide-react";
import { Button } from "../components/ui/button";
import { Card } from "../components/ui/card";
import { Badge } from "../components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "../components/ui/tabs";
import { useNavigate } from "react-router";

const myTrees = [
  { id: 1, name: "Park Maple", location: "Central Park", date: "Mar 7, 2026", emoji: "🍁" },
  { id: 2, name: "Street Oak", location: "5th Avenue", date: "Mar 5, 2026", emoji: "🌳" },
  { id: 3, name: "Garden Willow", location: "Riverside Park", date: "Mar 3, 2026", emoji: "🌿" },
  { id: 4, name: "Plaza Pine", location: "Union Square", date: "Mar 1, 2026", emoji: "🌲" },
];

const achievements = [
  { id: 1, title: "First Tree", description: "Registered your first tree", icon: "🌱", unlocked: true },
  { id: 2, title: "Tree Hunter", description: "Registered 10 trees", icon: "🎯", unlocked: true },
  { id: 3, title: "Guardian", description: "Registered 50 trees", icon: "🛡️", unlocked: true },
  { id: 4, title: "Forest Keeper", description: "Registered 100 trees", icon: "🏆", unlocked: false },
  { id: 5, title: "Community Leader", description: "Helped 50 people", icon: "⭐", unlocked: false },
  { id: 6, title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: true },
];

export default function Profile() {
  const navigate = useNavigate();

  const handleLogout = () => {
    navigate("/");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#F5F5F5] to-[#E8F5E9] pb-6">
      {/* Profile Header */}
      <div className="bg-gradient-to-br from-[#9C7A57] via-[#C49A6C] to-[#4CAF6D] px-6 pt-8 pb-24 rounded-b-3xl relative">
        <div className="flex justify-end gap-2 mb-8">
          <Button variant="ghost" size="icon" className="text-white hover:bg-white/20">
            <Settings className="w-5 h-5" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            onClick={handleLogout}
            className="text-white hover:bg-white/20"
          >
            <LogOut className="w-5 h-5" />
          </Button>
        </div>

        <div className="text-center">
          <div className="relative inline-block mb-4">
            <div className="w-24 h-24 rounded-full bg-white/20 backdrop-blur-lg flex items-center justify-center text-4xl">
              🌟
            </div>
            <button className="absolute bottom-0 right-0 w-8 h-8 rounded-full bg-[#4CAF6D] flex items-center justify-center shadow-lg">
              <Camera className="w-4 h-4 text-white" />
            </button>
          </div>

          <h1 className="text-2xl font-bold text-white mb-1">Sarah Chen</h1>
          <Badge className="bg-white/20 text-white border-0 backdrop-blur-lg">
            Guardian Level 5
          </Badge>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="px-6 -mt-16 mb-6">
        <div className="grid grid-cols-3 gap-3">
          <Card className="p-4 bg-white border-0 shadow-lg text-center">
            <TreePine className="w-6 h-6 text-[#4CAF6D] mx-auto mb-2" />
            <div className="text-2xl font-bold text-[#2E2E2E]">58</div>
            <div className="text-xs text-[#717171]">Trees</div>
          </Card>

          <Card className="p-4 bg-white border-0 shadow-lg text-center">
            <Coins className="w-6 h-6 text-[#9C7A57] mx-auto mb-2" />
            <div className="text-2xl font-bold text-[#2E2E2E]">1,240</div>
            <div className="text-xs text-[#717171]">Coins</div>
          </Card>

          <Card className="p-4 bg-white border-0 shadow-lg text-center">
            <Trophy className="w-6 h-6 text-[#6BCB77] mx-auto mb-2" />
            <div className="text-2xl font-bold text-[#2E2E2E]">12</div>
            <div className="text-xs text-[#717171]">Badges</div>
          </Card>
        </div>
      </div>

      {/* Impact Summary */}
      <div className="px-6 mb-6">
        <Card className="p-6 bg-gradient-to-br from-[#4CAF6D]/10 to-[#6BCB77]/10 border-0 shadow-md">
          <h2 className="font-bold text-[#2E2E2E] mb-4">Environmental Impact</h2>
          <div className="grid grid-cols-2 gap-4">
            <div className="text-center">
              <div className="text-3xl font-bold text-[#4CAF6D]">2.4t</div>
              <div className="text-sm text-[#717171]">CO₂ Offset</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-[#6BCB77]">145</div>
              <div className="text-sm text-[#717171]">Days Active</div>
            </div>
          </div>
        </Card>
      </div>

      {/* Tabs */}
      <div className="px-6">
        <Tabs defaultValue="trees" className="w-full">
          <TabsList className="w-full grid grid-cols-2 mb-6 bg-white h-12">
            <TabsTrigger
              value="trees"
              className="data-[state=active]:bg-[#4CAF6D] data-[state=active]:text-white"
            >
              My Trees
            </TabsTrigger>
            <TabsTrigger
              value="achievements"
              className="data-[state=active]:bg-[#4CAF6D] data-[state=active]:text-white"
            >
              Achievements
            </TabsTrigger>
          </TabsList>

          {/* My Trees Tab */}
          <TabsContent value="trees" className="space-y-3">
            {myTrees.map((tree) => (
              <Card
                key={tree.id}
                className="p-4 bg-white border-0 shadow-md hover:shadow-lg transition-shadow cursor-pointer"
                onClick={() => navigate(`/app/tree/${tree.id}`)}
              >
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] flex items-center justify-center text-2xl flex-shrink-0">
                    {tree.emoji}
                  </div>
                  <div className="flex-1">
                    <h3 className="font-bold text-[#2E2E2E]">{tree.name}</h3>
                    <div className="flex items-center gap-3 text-sm text-[#717171] mt-1">
                      <span>📍 {tree.location}</span>
                      <span>•</span>
                      <span>{tree.date}</span>
                    </div>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-[#4CAF6D]/10 flex items-center justify-center">
                    <span className="text-[#4CAF6D]">→</span>
                  </div>
                </div>
              </Card>
            ))}

            <Button className="w-full h-14 bg-gradient-to-r from-[#4CAF6D] to-[#6BCB77] hover:from-[#2E7D32] hover:to-[#4CAF6D] text-white rounded-2xl">
              Register Another Tree
            </Button>
          </TabsContent>

          {/* Achievements Tab */}
          <TabsContent value="achievements" className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              {achievements.map((achievement) => (
                <Card
                  key={achievement.id}
                  className={`p-4 border-0 ${
                    achievement.unlocked
                      ? "bg-white shadow-md"
                      : "bg-[#F5F5F5] opacity-60"
                  }`}
                >
                  <div className="text-center">
                    <div className={`text-4xl mb-2 ${achievement.unlocked ? "" : "grayscale"}`}>
                      {achievement.icon}
                    </div>
                    <h3 className={`font-bold text-sm mb-1 ${
                      achievement.unlocked ? "text-[#2E2E2E]" : "text-[#717171]"
                    }`}>
                      {achievement.title}
                    </h3>
                    <p className="text-xs text-[#717171]">{achievement.description}</p>
                    {achievement.unlocked && (
                      <Badge className="bg-[#4CAF6D] text-white mt-2">Unlocked</Badge>
                    )}
                  </div>
                </Card>
              ))}
            </div>

            <Card className="p-4 bg-gradient-to-r from-[#9C7A57]/10 to-[#C49A6C]/10 border-0">
              <div className="text-center">
                <div className="text-2xl mb-2">🏆</div>
                <p className="text-sm text-[#717171]">
                  Keep going! {achievements.filter((a) => !a.unlocked).length} more achievements to unlock
                </p>
              </div>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
