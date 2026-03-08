import { useState } from "react";
import { Heart, MessageCircle, Trophy, Flame } from "lucide-react";
import { Card } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Badge } from "../components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "../components/ui/tabs";

const communityPosts = [
  {
    id: 1,
    user: "Maria Garcia",
    avatar: "🌟",
    action: "registered a new tree",
    location: "Central Park",
    time: "2 hours ago",
    likes: 24,
    comments: 5,
    treeName: "Maple Guardian",
    treeEmoji: "🍁",
  },
  {
    id: 2,
    user: "John Smith",
    avatar: "🌲",
    action: "completed the Weekly Challenge",
    time: "5 hours ago",
    likes: 42,
    comments: 8,
    badge: "🏆",
  },
  {
    id: 3,
    user: "Emma Wilson",
    avatar: "🌳",
    action: "registered 3 trees today",
    location: "Riverside Park",
    time: "8 hours ago",
    likes: 36,
    comments: 12,
  },
  {
    id: 4,
    user: "Alex Chen",
    avatar: "🍃",
    action: "reached Guardian Level 5",
    time: "1 day ago",
    likes: 58,
    comments: 15,
    badge: "⭐",
  },
];

const challenges = [
  {
    id: 1,
    title: "Weekly Tree Hunter",
    description: "Register 10 trees this week",
    progress: 6,
    total: 10,
    reward: 200,
    icon: "🎯",
    participants: 1234,
  },
  {
    id: 2,
    title: "Species Explorer",
    description: "Find and register 5 different tree species",
    progress: 3,
    total: 5,
    reward: 150,
    icon: "🔍",
    participants: 856,
  },
  {
    id: 3,
    title: "Community Champion",
    description: "Help verify 20 tree reports",
    progress: 12,
    total: 20,
    reward: 100,
    icon: "🤝",
    participants: 645,
  },
];

const leaderboard = [
  { rank: 1, name: "Sarah Chen", trees: 156, coins: 8450, avatar: "🌟", trend: "up" },
  { rank: 2, name: "Mike Johnson", trees: 142, coins: 7890, avatar: "🌲", trend: "up" },
  { rank: 3, name: "Emma Davis", trees: 128, coins: 6950, avatar: "🌳", trend: "down" },
  { rank: 4, name: "You", trees: 58, coins: 1240, avatar: "🍃", trend: "up", isYou: true },
  { rank: 5, name: "Alex Brown", trees: 52, coins: 1180, avatar: "🌿", trend: "up" },
];

export default function Community() {
  const [likedPosts, setLikedPosts] = useState<number[]>([]);

  const toggleLike = (postId: number) => {
    setLikedPosts((prev) =>
      prev.includes(postId)
        ? prev.filter((id) => id !== postId)
        : [...prev, postId]
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#F5F5F5] to-[#E8F5E9] pb-6">
      {/* Header */}
      <div className="bg-gradient-to-r from-[#4CAF6D] to-[#6BCB77] px-6 py-8 rounded-b-3xl mb-6">
        <h1 className="text-3xl font-bold text-white mb-2">Community</h1>
        <p className="text-white/90">Connect with fellow tree guardians</p>
      </div>

      <div className="px-6">
        <Tabs defaultValue="feed" className="w-full">
          <TabsList className="w-full grid grid-cols-3 mb-6 bg-white h-12">
            <TabsTrigger value="feed" className="data-[state=active]:bg-[#4CAF6D] data-[state=active]:text-white">
              Feed
            </TabsTrigger>
            <TabsTrigger value="challenges" className="data-[state=active]:bg-[#4CAF6D] data-[state=active]:text-white">
              Challenges
            </TabsTrigger>
            <TabsTrigger value="leaderboard" className="data-[state=active]:bg-[#4CAF6D] data-[state=active]:text-white">
              Leaderboard
            </TabsTrigger>
          </TabsList>

          {/* Feed Tab */}
          <TabsContent value="feed" className="space-y-4">
            {communityPosts.map((post) => (
              <Card key={post.id} className="p-5 bg-white border-0 shadow-md">
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] flex items-center justify-center text-2xl flex-shrink-0">
                    {post.avatar}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-baseline gap-2 flex-wrap">
                      <span className="font-bold text-[#2E2E2E]">{post.user}</span>
                      <span className="text-[#717171]">{post.action}</span>
                    </div>
                    {post.location && (
                      <div className="text-sm text-[#717171]">📍 {post.location}</div>
                    )}
                    <div className="text-xs text-[#717171] mt-1">{post.time}</div>
                  </div>
                  {post.badge && (
                    <div className="text-3xl">{post.badge}</div>
                  )}
                </div>

                {post.treeName && (
                  <div className="bg-gradient-to-br from-[#F5F5F5] to-[#E8F5E9] rounded-xl p-4 mb-3">
                    <div className="flex items-center gap-3">
                      <div className="text-4xl">{post.treeEmoji}</div>
                      <div>
                        <div className="font-bold text-[#2E2E2E]">{post.treeName}</div>
                        <div className="text-sm text-[#717171]">New tree registered</div>
                      </div>
                    </div>
                  </div>
                )}

                <div className="flex items-center gap-4 pt-3 border-t border-[#E8E8E8]">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => toggleLike(post.id)}
                    className={`flex items-center gap-2 ${
                      likedPosts.includes(post.id)
                        ? "text-[#4CAF6D]"
                        : "text-[#717171]"
                    }`}
                  >
                    <Heart
                      className={`w-5 h-5 ${
                        likedPosts.includes(post.id) ? "fill-current" : ""
                      }`}
                    />
                    <span>{post.likes + (likedPosts.includes(post.id) ? 1 : 0)}</span>
                  </Button>
                  <Button variant="ghost" size="sm" className="flex items-center gap-2 text-[#717171]">
                    <MessageCircle className="w-5 h-5" />
                    <span>{post.comments}</span>
                  </Button>
                </div>
              </Card>
            ))}
          </TabsContent>

          {/* Challenges Tab */}
          <TabsContent value="challenges" className="space-y-4">
            {challenges.map((challenge) => (
              <Card key={challenge.id} className="p-5 bg-white border-0 shadow-md">
                <div className="flex items-start gap-4">
                  <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] flex items-center justify-center text-3xl flex-shrink-0">
                    {challenge.icon}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <h3 className="font-bold text-[#2E2E2E]">{challenge.title}</h3>
                        <p className="text-sm text-[#717171]">{challenge.description}</p>
                      </div>
                      <Badge className="bg-[#9C7A57] text-white">
                        +{challenge.reward} 🪙
                      </Badge>
                    </div>

                    <div className="space-y-2 mt-4">
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-[#717171]">Progress</span>
                        <span className="font-bold text-[#4CAF6D]">
                          {challenge.progress}/{challenge.total}
                        </span>
                      </div>
                      <div className="h-3 bg-[#F5F5F5] rounded-full overflow-hidden">
                        <div
                          className="h-full bg-gradient-to-r from-[#4CAF6D] to-[#6BCB77] rounded-full transition-all"
                          style={{ width: `${(challenge.progress / challenge.total) * 100}%` }}
                        ></div>
                      </div>
                      <div className="flex items-center gap-1 text-xs text-[#717171]">
                        <Flame className="w-4 h-4" />
                        <span>{challenge.participants.toLocaleString()} participants</span>
                      </div>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </TabsContent>

          {/* Leaderboard Tab */}
          <TabsContent value="leaderboard" className="space-y-3">
            {leaderboard.map((user) => (
              <Card
                key={user.rank}
                className={`p-5 border-0 shadow-md ${
                  user.isYou
                    ? "bg-gradient-to-r from-[#4CAF6D]/10 to-[#6BCB77]/10 border-2 border-[#4CAF6D]"
                    : "bg-white"
                }`}
              >
                <div className="flex items-center gap-4">
                  <div className={`text-3xl font-bold ${
                    user.rank === 1 ? "text-[#FFD700]" :
                    user.rank === 2 ? "text-[#C0C0C0]" :
                    user.rank === 3 ? "text-[#CD7F32]" :
                    "text-[#717171]"
                  }`}>
                    #{user.rank}
                  </div>

                  <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#9C7A57] to-[#C49A6C] flex items-center justify-center text-2xl flex-shrink-0">
                    {user.avatar}
                  </div>

                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className={`font-bold ${user.isYou ? "text-[#4CAF6D]" : "text-[#2E2E2E]"}`}>
                        {user.name}
                      </span>
                      {user.isYou && (
                        <Badge className="bg-[#4CAF6D] text-white text-xs">You</Badge>
                      )}
                    </div>
                    <div className="flex items-center gap-4 text-sm text-[#717171] mt-1">
                      <span>🌳 {user.trees} trees</span>
                      <span>🪙 {user.coins.toLocaleString()}</span>
                    </div>
                  </div>

                  <div className="text-right">
                    <Trophy className={`w-6 h-6 mx-auto mb-1 ${
                      user.rank <= 3 ? "text-[#4CAF6D]" : "text-[#717171]"
                    }`} />
                    <span className={`text-xs ${
                      user.trend === "up" ? "text-[#4CAF6D]" : "text-[#9C7A57]"
                    }`}>
                      {user.trend === "up" ? "↑" : "↓"}
                    </span>
                  </div>
                </div>
              </Card>
            ))}
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
