import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Time "mo:base/Time";

actor CoinStatistics {
    let api_key = "ccfa76b8-a631-41e6-b1fe-3f70a683e87d"; 
    func hash(n: Nat): Hash.Hash { Hash.hash(n) };
    func equal(n1: Nat, n2: Nat): Bool { n1 == n2 };

    // Added timeLogs for heads and tails
    var stats : HashMap.HashMap<Nat, { heads : Nat; tails : Nat; timeLogsHeads: [Time.Time]; timeLogsTails: [Time.Time] }> = 
        HashMap.HashMap<Nat, { heads : Nat; tails : Nat; timeLogsHeads: [Time.Time]; timeLogsTails: [Time.Time] }>(8, equal, hash);

    public func incrementHeads(apiKey: Text, coinId: Nat): async Text {
        if (apiKey == api_key) {
            let currentTime = Time.now();
            let currentStats = switch (stats.get(coinId)) {
                case (null) { { heads = 0; tails = 0; timeLogsHeads = []; timeLogsTails = [] } };
                case (?s) { s };
            };
            let newStats = { heads = currentStats.heads + 1; tails = currentStats.tails; timeLogsHeads = Array.append(currentStats.timeLogsHeads, [currentTime]); timeLogsTails = currentStats.timeLogsTails };
            stats.put(coinId, newStats);
            return "Heads incremented successfully";
        } else {
            return "Unauthorized: Invalid API key";
        }
    };

    public func incrementTails(apiKey: Text, coinId: Nat): async Text {
        if (apiKey == api_key) {
            let currentTime = Time.now();
            let currentStats = switch (stats.get(coinId)) {
                case (null) { { heads = 0; tails = 0; timeLogsHeads = []; timeLogsTails = [] } };
                case (?s) { s };
            };
            let newStats = { heads = currentStats.heads; tails = currentStats.tails + 1; timeLogsHeads = currentStats.timeLogsHeads; timeLogsTails = Array.append(currentStats.timeLogsTails, [currentTime]) };
            stats.put(coinId, newStats);
            return "Tails incremented successfully";
        } else {
            return "Unauthorized: Invalid API key";
        }
    };
public query func getStatistics(coinId: Nat): async ?{ flips: Nat; heads: Nat; tails: Nat } {
        switch (stats.get(coinId)) {
            case (null) { return null };
            case (?s) {
                let flips = s.heads + s.tails;
                return ?{ flips = flips; heads = s.heads; tails = s.tails };
            };
        };
    };
public query func getStatisticsWithTimestamps(coinId: Nat): async ?{ flips: Nat; heads: Nat; tails: Nat; timeLogsHeads: [Time.Time]; timeLogsTails: [Time.Time] } {
    switch (stats.get(coinId)) {
        case (null) { return null };
        case (?s) {
            let flips = s.heads + s.tails;
            return ?{
                flips = flips; 
                heads = s.heads; 
                tails = s.tails;
                timeLogsHeads = s.timeLogsHeads;
                timeLogsTails = s.timeLogsTails
            };
        };
    };
};

   public query func getAllStatistics(): async ?[{ coinId: Nat; flips: Nat; heads: Nat; tails: Nat }] {
        let allEntries = Iter.toArray(stats.entries());
        let allStats = Array.map<(Nat, {heads: Nat; tails: Nat; timeLogsHeads: [Time.Time]; timeLogsTails: [Time.Time]}), {coinId: Nat; flips: Nat; heads: Nat; tails: Nat}>(allEntries, func((coinId, s)) {
            let flips = s.heads + s.tails;
            return {coinId = coinId; flips = flips; heads = s.heads; tails = s.tails};
        });
        ?allStats
    };

    public query func getAllHeadsWithTimestamps(): async ?[{ coinId: Nat; heads: Nat; timeLogs: [Time.Time] }] {
        let allEntries = Iter.toArray(stats.entries());
        let allHeads = Array.map<(Nat, {heads: Nat; timeLogsHeads: [Time.Time]}), {coinId: Nat; heads: Nat; timeLogs: [Time.Time]}>(allEntries, func((coinId, s)) {
            return {coinId = coinId; heads = s.heads; timeLogs = s.timeLogsHeads};
        });
        ?allHeads
    };

    public query func getAllTailsWithTimestamps(): async ?[{ coinId: Nat; tails: Nat; timeLogs: [Time.Time] }] {
        let allEntries = Iter.toArray(stats.entries());
        let allTails = Array.map<(Nat, {tails: Nat; timeLogsTails: [Time.Time]}), {coinId: Nat; tails: Nat; timeLogs: [Time.Time]}>(allEntries, func((coinId, s)) {
            return {coinId = coinId; tails = s.tails; timeLogs = s.timeLogsTails};
        });
        ?allTails
    };

    public query func getAllFlipsWithTimestamps(): async ?[{ coinId: Nat; flips: Nat; timeLogsHeads: [Time.Time]; timeLogsTails: [Time.Time] }] {
        let allEntries = Iter.toArray(stats.entries());
        let allFlips = Array.map<(Nat, {heads: Nat; tails: Nat; timeLogsHeads: [Time.Time]; timeLogsTails: [Time.Time]}), {coinId: Nat; flips: Nat; timeLogsHeads: [Time.Time]; timeLogsTails: [Time.Time]}>(allEntries, func((coinId, s)) {
            let flips = s.heads + s.tails;
            return {coinId = coinId; flips = flips; timeLogsHeads = s.timeLogsHeads; timeLogsTails = s.timeLogsTails};
        });
        ?allFlips
    };
};
