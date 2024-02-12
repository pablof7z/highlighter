import type { Config } from "jest";

const config: Config = {
    preset: "ts-jest",
    testEnvironment: "node",
    testTimeout: 10000,
    moduleNameMapper: {
        "^(\\.{1,2}/.*)\\.ts$": "$1",
    },
};

export default config;