import { Text, View } from 'react-native';

export default function App() {
  const testVar = process.env.EXPO_PUBLIC_TEST_VAR || 'not set';
  return (
    <View>
      <Text>EXPO_PUBLIC_TEST_VAR: {testVar}</Text>
    </View>
  );
}
