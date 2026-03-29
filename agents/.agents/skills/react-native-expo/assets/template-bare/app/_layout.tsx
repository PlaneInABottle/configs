import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { RootStoreProvider } from "@/stores/RootStore";
import "../global.css";

export default function RootLayout() {
  return (
    <RootStoreProvider>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerShown: false,
        }}
      />
    </RootStoreProvider>
  );
}
