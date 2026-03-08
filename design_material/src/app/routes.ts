import { createBrowserRouter } from "react-router";
import Login from "./screens/Login";
import Register from "./screens/Register";
import Dashboard from "./screens/Dashboard";
import Map from "./screens/Map";
import RegisterTreeCamera from "./screens/RegisterTreeCamera";
import RegisterTreeLocation from "./screens/RegisterTreeLocation";
import RegisterTreeName from "./screens/RegisterTreeName";
import TreeProfile from "./screens/TreeProfile";
import Community from "./screens/Community";
import Social from "./screens/Social";
import Profile from "./screens/Profile";
import MainLayout from "./components/MainLayout";
import NotFound from "./screens/NotFound";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Login,
  },
  {
    path: "/register",
    Component: Register,
  },
  {
    path: "/app",
    Component: MainLayout,
    children: [
      { index: true, Component: Dashboard },
      { path: "map", Component: Map },
      { path: "social", Component: Social },
      { path: "community", Component: Community },
      { path: "profile", Component: Profile },
      { path: "register-tree/camera", Component: RegisterTreeCamera },
      { path: "register-tree/location", Component: RegisterTreeLocation },
      { path: "register-tree/name", Component: RegisterTreeName },
      { path: "tree/:id", Component: TreeProfile },
    ],
  },
  {
    path: "*",
    Component: NotFound,
  },
]);