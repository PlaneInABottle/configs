import { FlatList, View } from "react-native";
import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";

const SAMPLE_DATA = [
  { id: "1", title: "Getting Started", description: "Learn the basics of this template." },
  { id: "2", title: "State Management", description: "MobX stores are in the stores/ directory." },
  { id: "3", title: "Styling", description: "NativeWind (Tailwind CSS) is used for styling." },
  { id: "4", title: "Routing", description: "Expo Router provides file-based navigation." },
];

export default function ExploreScreen() {
  return (
    <ThemedView className="flex-1 px-4 pt-4">
      <ThemedText type="title" className="mb-4">
        Explore
      </ThemedText>
      <FlatList
        data={SAMPLE_DATA}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View className="mb-3 rounded-xl bg-gray-100 dark:bg-gray-800 p-4">
            <ThemedText type="defaultSemiBold">{item.title}</ThemedText>
            <ThemedText
              type="default"
              className="mt-1 text-gray-500 dark:text-gray-400"
            >
              {item.description}
            </ThemedText>
          </View>
        )}
      />
    </ThemedView>
  );
}
