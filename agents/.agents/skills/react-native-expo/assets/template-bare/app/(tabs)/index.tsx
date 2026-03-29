import { View, Text, Pressable } from "react-native";
import { observer } from "mobx-react-lite";
import { useUserStore } from "@/stores/RootStore";
import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";

export default observer(function HomeScreen() {
  const userStore = useUserStore();

  return (
    <ThemedView className="flex-1 items-center justify-center px-6">
      <ThemedText type="title" className="mb-4">
        Welcome
      </ThemedText>

      {userStore.isLoggedIn && userStore.user ? (
        <View className="items-center gap-2">
          <ThemedText type="defaultSemiBold">
            Hello, {userStore.user.name}!
          </ThemedText>
          <ThemedText type="default" className="text-gray-500 dark:text-gray-400">
            {userStore.user.email}
          </ThemedText>
          <Pressable
            onPress={() => userStore.clearUser()}
            className="mt-4 rounded-lg bg-red-500 px-4 py-2"
          >
            <Text className="text-white font-semibold">Sign Out</Text>
          </Pressable>
        </View>
      ) : (
        <View className="items-center gap-2">
          <ThemedText type="default" className="text-gray-500 dark:text-gray-400">
            You are not signed in.
          </ThemedText>
          <Pressable
            onPress={() =>
              userStore.setUser({
                id: "1",
                name: "Jane Doe",
                email: "jane@example.com",
              })
            }
            className="mt-4 rounded-lg bg-blue-500 px-4 py-2"
          >
            <Text className="text-white font-semibold">Sign In (Demo)</Text>
          </Pressable>
        </View>
      )}
    </ThemedView>
  );
});
