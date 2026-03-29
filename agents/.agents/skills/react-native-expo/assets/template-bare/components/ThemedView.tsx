import { View, type ViewProps } from "react-native";

export type ThemedViewProps = ViewProps & {
  lightColor?: string;
  darkColor?: string;
};

export function ThemedView({
  style,
  lightColor,
  darkColor,
  className,
  ...rest
}: ThemedViewProps & { className?: string }) {
  return (
    <View
      className={`bg-light-background dark:bg-dark-background ${className ?? ""}`}
      style={style}
      {...rest}
    />
  );
}
