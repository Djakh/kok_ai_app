import { useState } from "react";
import {
  Heart,
  MessageCircle,
  Share2,
  Image as ImageIcon,
  Send,
  X,
  TreePine,
  MapPin,
} from "lucide-react";
import { Card } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Textarea } from "../components/ui/textarea";
import { Input } from "../components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "../components/ui/dialog";

interface Comment {
  id: number;
  user: string;
  avatar: string;
  text: string;
  time: string;
}

interface Post {
  id: number;
  user: string;
  avatar: string;
  title: string;
  time: string;
  content: string;
  image?: string;
  treeData?: {
    name: string;
    location: string;
  };
  likes: number;
  commentsCount: number;
  comments: Comment[];
}

const initialPosts: Post[] = [
  {
    id: 1,
    user: "Maria Garcia",
    avatar: "🌟",
    title: "Tree Guardian • Level 4",
    time: "2 hours ago",
    content:
      "Just registered my 50th tree! 🎉 Found this beautiful oak in Central Park. It's amazing how many trees we miss in our daily walks. This app has completely changed how I see my city! #TreeGuardian #UrbanForest",
    image: "oak",
    treeData: {
      name: "Grand Oak",
      location: "Central Park, NY",
    },
    likes: 42,
    commentsCount: 8,
    comments: [
      {
        id: 1,
        user: "John Smith",
        avatar: "🌲",
        text: "Congratulations Maria! That's an impressive milestone 🌳",
        time: "1 hour ago",
      },
      {
        id: 2,
        user: "Emma Wilson",
        avatar: "🌳",
        text: "Beautiful tree! I walk past Central Park every day, will look for it!",
        time: "45 min ago",
      },
    ],
  },
  {
    id: 2,
    user: "Alex Chen",
    avatar: "🍃",
    title: "Environmental Advocate",
    time: "5 hours ago",
    content:
      "Completed the weekly challenge! Registered 10 trees across 3 different neighborhoods. The diversity of species is incredible. Did you know that urban trees can reduce air temperature by up to 10°F? Let's keep our cities green! 🌿",
    likes: 67,
    commentsCount: 12,
    comments: [
      {
        id: 1,
        user: "Sarah Chen",
        avatar: "🌟",
        text: "Amazing work Alex! Which neighborhood had the most variety?",
        time: "4 hours ago",
      },
    ],
  },
  {
    id: 3,
    user: "Sarah Chen",
    avatar: "🌟",
    title: "Top Guardian • Level 5",
    time: "1 day ago",
    content:
      "Organized a community tree walk this weekend! 15 people joined and we registered 23 new trees together. The power of community action is real. Who wants to join next week? 🚶‍♀️🌳",
    image: "community",
    likes: 89,
    commentsCount: 24,
    comments: [
      {
        id: 1,
        user: "Mike Johnson",
        avatar: "🌲",
        text: "Count me in for next week! What area are you covering?",
        time: "1 day ago",
      },
      {
        id: 2,
        user: "Emma Davis",
        avatar: "🌿",
        text: "This is such a great initiative! I'd love to join too 🙋‍♀️",
        time: "20 hours ago",
      },
    ],
  },
];

export default function Social() {
  const [posts, setPosts] = useState<Post[]>(initialPosts);
  const [likedPosts, setLikedPosts] = useState<number[]>([]);
  const [expandedComments, setExpandedComments] = useState<number[]>([]);
  const [commentTexts, setCommentTexts] = useState<{ [key: number]: string }>({});
  const [showCreatePost, setShowCreatePost] = useState(false);
  const [newPostContent, setNewPostContent] = useState("");
  const [newPostImage, setNewPostImage] = useState<string | null>(null);

  const toggleLike = (postId: number) => {
    setLikedPosts((prev) =>
      prev.includes(postId) ? prev.filter((id) => id !== postId) : [...prev, postId]
    );
  };

  const toggleComments = (postId: number) => {
    setExpandedComments((prev) =>
      prev.includes(postId) ? prev.filter((id) => id !== postId) : [...prev, postId]
    );
  };

  const handleAddComment = (postId: number) => {
    const commentText = commentTexts[postId]?.trim();
    if (!commentText) return;

    setPosts((prevPosts) =>
      prevPosts.map((post) =>
        post.id === postId
          ? {
              ...post,
              comments: [
                ...post.comments,
                {
                  id: post.comments.length + 1,
                  user: "You",
                  avatar: "🍃",
                  text: commentText,
                  time: "Just now",
                },
              ],
              commentsCount: post.commentsCount + 1,
            }
          : post
      )
    );

    setCommentTexts((prev) => ({ ...prev, [postId]: "" }));
  };

  const handleCreatePost = () => {
    if (!newPostContent.trim()) return;

    const newPost: Post = {
      id: posts.length + 1,
      user: "You",
      avatar: "🍃",
      title: "Tree Guardian",
      time: "Just now",
      content: newPostContent,
      image: newPostImage || undefined,
      likes: 0,
      commentsCount: 0,
      comments: [],
    };

    setPosts([newPost, ...posts]);
    setNewPostContent("");
    setNewPostImage(null);
    setShowCreatePost(false);
  };

  const handleImageUpload = () => {
    // Mock image upload - in reality would use file input
    setNewPostImage("uploaded");
  };

  return (
    <div className="min-h-screen bg-[#F5F5F5]">
      {/* Header */}
      <div className="bg-white px-6 py-4 shadow-sm sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-[#2E2E2E]">Social</h1>
          <Button
            onClick={() => setShowCreatePost(true)}
            className="bg-[#4CAF6D] hover:bg-[#2E7D32] text-white rounded-xl"
          >
            Create Post
          </Button>
        </div>
      </div>

      {/* Create Post Dialog */}
      <Dialog open={showCreatePost} onOpenChange={setShowCreatePost}>
        <DialogContent className="max-w-[440px] bg-white">
          <DialogHeader>
            <DialogTitle className="text-[#2E2E2E]">Create a Post</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] flex items-center justify-center text-2xl">
                🍃
              </div>
              <div>
                <div className="font-bold text-[#2E2E2E]">You</div>
                <div className="text-sm text-[#717171]">Tree Guardian</div>
              </div>
            </div>

            <Textarea
              placeholder="Share your tree discovery, achievement, or thoughts..."
              value={newPostContent}
              onChange={(e) => setNewPostContent(e.target.value)}
              className="min-h-32 border-[#E8E8E8] focus:border-[#4CAF6D] resize-none"
            />

            {newPostImage && (
              <div className="relative">
                <div className="w-full h-48 bg-gradient-to-br from-[#4CAF6D]/20 to-[#6BCB77]/20 rounded-xl flex items-center justify-center">
                  <TreePine className="w-16 h-16 text-[#4CAF6D]" />
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => setNewPostImage(null)}
                  className="absolute top-2 right-2 bg-white/90 hover:bg-white"
                >
                  <X className="w-4 h-4" />
                </Button>
              </div>
            )}

            <div className="flex items-center justify-between pt-4 border-t border-[#E8E8E8]">
              <Button
                variant="ghost"
                onClick={handleImageUpload}
                className="text-[#717171] hover:text-[#4CAF6D]"
              >
                <ImageIcon className="w-5 h-5 mr-2" />
                Add Photo
              </Button>

              <Button
                onClick={handleCreatePost}
                disabled={!newPostContent.trim()}
                className="bg-[#4CAF6D] hover:bg-[#2E7D32] text-white rounded-xl"
              >
                Post
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Posts Feed */}
      <div className="px-6 py-4 space-y-4">
        {posts.map((post) => (
          <Card key={post.id} className="p-0 bg-white border-0 shadow-md overflow-hidden">
            {/* Post Header */}
            <div className="p-5 pb-4">
              <div className="flex items-start gap-3 mb-4">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#9C7A57] to-[#C49A6C] flex items-center justify-center text-2xl flex-shrink-0">
                  {post.avatar}
                </div>
                <div className="flex-1">
                  <div className="font-bold text-[#2E2E2E]">{post.user}</div>
                  <div className="text-sm text-[#717171]">{post.title}</div>
                  <div className="text-xs text-[#717171] mt-0.5">{post.time}</div>
                </div>
              </div>

              {/* Post Content */}
              <p className="text-[#2E2E2E] whitespace-pre-line leading-relaxed">
                {post.content}
              </p>
            </div>

            {/* Post Image */}
            {post.image && (
              <div className="w-full bg-gradient-to-br from-[#E8F5E9] to-[#F5F5DC] flex items-center justify-center relative">
                <div className="py-16">
                  <TreePine className="w-24 h-24 text-[#4CAF6D]" />
                </div>
                {post.treeData && (
                  <div className="absolute bottom-4 left-4 right-4 bg-white/95 backdrop-blur-sm rounded-xl p-3">
                    <div className="flex items-center gap-2">
                      <TreePine className="w-5 h-5 text-[#4CAF6D]" />
                      <div className="flex-1">
                        <div className="font-bold text-sm text-[#2E2E2E]">
                          {post.treeData.name}
                        </div>
                        <div className="text-xs text-[#717171] flex items-center gap-1">
                          <MapPin className="w-3 h-3" />
                          {post.treeData.location}
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            )}

            {/* Post Actions */}
            <div className="px-5 py-3 border-t border-[#E8E8E8]">
              <div className="flex items-center justify-between text-sm text-[#717171] mb-2">
                <span>
                  {post.likes + (likedPosts.includes(post.id) ? 1 : 0)} likes
                </span>
                <span>{post.commentsCount} comments</span>
              </div>

              <div className="flex items-center gap-1 pt-2 border-t border-[#E8E8E8]">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => toggleLike(post.id)}
                  className={`flex-1 ${
                    likedPosts.includes(post.id)
                      ? "text-[#4CAF6D]"
                      : "text-[#717171] hover:text-[#4CAF6D]"
                  }`}
                >
                  <Heart
                    className={`w-5 h-5 mr-2 ${
                      likedPosts.includes(post.id) ? "fill-current" : ""
                    }`}
                  />
                  Like
                </Button>

                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => toggleComments(post.id)}
                  className="flex-1 text-[#717171] hover:text-[#4CAF6D]"
                >
                  <MessageCircle className="w-5 h-5 mr-2" />
                  Comment
                </Button>

                <Button
                  variant="ghost"
                  size="sm"
                  className="flex-1 text-[#717171] hover:text-[#4CAF6D]"
                >
                  <Share2 className="w-5 h-5 mr-2" />
                  Share
                </Button>
              </div>
            </div>

            {/* Comments Section */}
            {expandedComments.includes(post.id) && (
              <div className="px-5 pb-5 pt-2 bg-[#F5F5F5] border-t border-[#E8E8E8]">
                {/* Existing Comments */}
                <div className="space-y-4 mb-4">
                  {post.comments.map((comment) => (
                    <div key={comment.id} className="flex gap-3">
                      <div className="w-9 h-9 rounded-full bg-gradient-to-br from-[#6BCB77] to-[#4CAF6D] flex items-center justify-center text-lg flex-shrink-0">
                        {comment.avatar}
                      </div>
                      <div className="flex-1">
                        <div className="bg-white rounded-2xl px-4 py-2.5">
                          <div className="font-medium text-sm text-[#2E2E2E]">
                            {comment.user}
                          </div>
                          <p className="text-sm text-[#2E2E2E] mt-0.5">
                            {comment.text}
                          </p>
                        </div>
                        <div className="text-xs text-[#717171] mt-1 px-4">
                          {comment.time}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Add Comment */}
                <div className="flex gap-2">
                  <div className="w-9 h-9 rounded-full bg-gradient-to-br from-[#4CAF6D] to-[#6BCB77] flex items-center justify-center text-lg flex-shrink-0">
                    🍃
                  </div>
                  <div className="flex-1 flex gap-2">
                    <Input
                      placeholder="Write a comment..."
                      value={commentTexts[post.id] || ""}
                      onChange={(e) =>
                        setCommentTexts((prev) => ({
                          ...prev,
                          [post.id]: e.target.value,
                        }))
                      }
                      onKeyDown={(e) => {
                        if (e.key === "Enter" && !e.shiftKey) {
                          e.preventDefault();
                          handleAddComment(post.id);
                        }
                      }}
                      className="bg-white border-[#E8E8E8] focus:border-[#4CAF6D] rounded-full h-9"
                    />
                    <Button
                      size="icon"
                      onClick={() => handleAddComment(post.id)}
                      disabled={!commentTexts[post.id]?.trim()}
                      className="h-9 w-9 rounded-full bg-[#4CAF6D] hover:bg-[#2E7D32] text-white flex-shrink-0"
                    >
                      <Send className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </div>
            )}
          </Card>
        ))}
      </div>
    </div>
  );
}
