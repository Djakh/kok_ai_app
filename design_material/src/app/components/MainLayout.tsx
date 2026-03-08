import { Outlet, useLocation, Link } from "react-router";
import { Home, Map, MessageSquare, User } from "lucide-react";

export default function MainLayout() {
  const location = useLocation();

  const navItems = [
    { path: "/app", icon: Home, label: "Dashboard" },
    { path: "/app/map", icon: Map, label: "Map" },
    { path: "/app/social", icon: MessageSquare, label: "Social" },
    { path: "/app/profile", icon: User, label: "Profile" },
  ];

  // Don't show bottom nav on register tree flow
  const hideBottomNav = location.pathname.includes("/register-tree");

  return (
    <div className="flex flex-col h-screen bg-[#F5F5F5] max-w-[480px] mx-auto">
      <main className={`flex-1 overflow-auto ${hideBottomNav ? "" : "pb-20"}`}>
        <Outlet />
      </main>

      {!hideBottomNav && (
        <nav className="fixed bottom-0 left-0 right-0 max-w-[480px] mx-auto bg-white border-t border-[#E8E8E8] z-50">
          <div className="flex justify-around items-center h-16">
            {navItems.map((item) => {
              const isActive = location.pathname === item.path;
              const Icon = item.icon;
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className="flex flex-col items-center justify-center flex-1 h-full"
                >
                  <Icon
                    className={`w-6 h-6 ${
                      isActive ? "text-[#4CAF6D]" : "text-[#717171]"
                    }`}
                  />
                  <span
                    className={`text-xs mt-1 ${
                      isActive ? "text-[#4CAF6D]" : "text-[#717171]"
                    }`}
                  >
                    {item.label}
                  </span>
                </Link>
              );
            })}
          </div>
        </nav>
      )}
    </div>
  );
}