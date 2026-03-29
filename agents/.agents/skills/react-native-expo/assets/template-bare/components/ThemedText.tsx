import { Text, type TextProps } from "react-native";

export type ThemedTextProps = TextProps & {
  lightColor?: string;
  darkColor?: string;
  type?: "default" | "title" | "defaultSemiBold" | "subtitle" | "link";
};

export function ThemedText({
  style,
  lightColor,
  darkColor,
  type = "default",
  className,
  ...rest
}: ThemedTextProps & { className?: string }) {
  return (
    <Text
      className={`
        text-light-text dark:text-dark-text
        ${type === "default" ? "text-base leading-6" : ""}
        ${type === "title" ? "text-3xl font-bold leading-8" : ""}
        ${type === "defaultSemiBold" ? "text-base font-semibold leading-6" : ""}
        ${type === "subtitle" ? "text-xl font-bold" : ""}
        ${type === "link" ? "text-base leading-6 text-light-tint dark:text-dark-tint" : ""}
        ${className ?? ""}
      `}
      style={style}
      {...rest}
    />
  );
}
