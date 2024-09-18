// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: @openzeppelin/contracts/utils/structs/EnumerableMap.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableMap.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableMap.js.

pragma solidity ^0.8.20;


/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32Map`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableMap.
 * ====
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code repetition as possible, we write it in
    // terms of a generic Map type with bytes32 keys and values. The Map implementation uses private functions,
    // and user-facing implementations such as `UintToAddressMap` are just wrappers around the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit in bytes32.

    /**
     * @dev Query for a nonexistent map key.
     */
    error EnumerableMapNonexistentKey(bytes32 key);

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 key => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToBytes32Map storage map, bytes32 key, bytes32 value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        if (value == 0 && !contains(map, key)) {
            revert EnumerableMapNonexistentKey(key);
        }
        return value;
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToBytes32Map storage map) internal view returns (bytes32[] memory) {
        return map._keys.values();
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToUintMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToAddressMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToUintMap storage map, address key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToUintMap storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToUintMap storage map, bytes32 key, uint256 value) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToUintMap storage map) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: @openzeppelin/contracts/utils/structs/BitMaps.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/BitMaps.sol)
pragma solidity ^0.8.20;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 *
 * BitMaps pack 256 booleans across each bit of a single 256-bit slot of `uint256` type.
 * Hence booleans corresponding to 256 _sequential_ indices would only consume a single slot,
 * unlike the regular `bool` which would consume an entire slot for a single value.
 *
 * This results in gas savings in two ways:
 *
 * - Setting a zero value to non-zero only once every 256 times
 * - Accessing the same warm slot for every 256 _sequential_ indices
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 bucket => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(BitMap storage bitmap, uint256 index, bool value) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}

// File: MintDBTC/artifacts/MintDBTC/interface/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: MintDBTC/artifacts/MintDBTC/interface/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;





library SafeERC20 {
    using Address for address;

    error SafeERC20FailedOperation(address token);

    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }


    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: MintDBTC/artifacts/MintDBTC/interface/ISwapRouter.sol


pragma solidity ^0.8.0;

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}


// File: MintDBTC/artifacts/MintDBTC/interface/ISwapPair.sol


pragma solidity ^0.8.0;

interface ISwapPair {
    function getReserves()
    external
    view
    returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function skim(address to) external;

    function sync() external;
}


// File: MintDBTC/artifacts/MintDBTC/interface/ISwapFactory.sol


pragma solidity ^0.8.0;

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}


// File: MintDBTC/artifacts/MintDBTC/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with using Counters for Counters.Counter;
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// File: MintDBTC/artifacts/MintDBTC/DoubleEndedQueue.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/DoubleEndedQueue.sol)
pragma solidity ^0.8.20;

/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `Uint256Deque`. Other types can be cast to and from `uint256`. This data structure can only be
 * used in storage, and not in memory.
 * ```solidity
 * DoubleEndedQueue.Uint256Deque queue;
 * ```
 */
library DoubleEndedQueue {
    /**
     * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
     */
    error QueueEmpty();

    /**
     * @dev A push operation couldn't be completed due to the queue being full.
     */
    error QueueFull();

    /**
     * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
     */
    error QueueOutOfBounds();

    /**
     * @dev Indices are 128 bits so begin and end are packed in a single storage slot for efficient access.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * The first item is at data[begin] and the last item is at data[end - 1]. This range can wrap around.
     */
    struct Uint256Deque {
        uint128 _begin;
        uint128 _end;
        mapping(uint128 => uint256) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue.
     *
     * Reverts with {QueueFull} if the queue is full.
     */
    function pushBack(Uint256Deque storage deque, uint256 value) internal {
        unchecked {
            uint128 backIndex = deque._end;
            if (backIndex + 1 == deque._begin) revert QueueFull();
            deque._data[backIndex] = value;
            deque._end = backIndex + 1;
        }
    }

    /**
     * @dev Removes the item at the end of the queue and returns it.
     *
     * Reverts with {QueueEmpty} if the queue is empty.
     */
    function popBack(Uint256Deque storage deque) internal returns (uint256 value) {
        unchecked {
            uint128 backIndex = deque._end;
            if (backIndex == deque._begin) revert QueueEmpty();
            --backIndex;
            value = deque._data[backIndex];
            delete deque._data[backIndex];
            deque._end = backIndex;
        }
    }

    /**
     * @dev Inserts an item at the beginning of the queue.
     *
     * Reverts with {QueueFull} if the queue is full.
     */
    function pushFront(Uint256Deque storage deque, uint256 value) internal {
        unchecked {
            uint128 frontIndex = deque._begin - 1;
            if (frontIndex == deque._end) revert QueueFull();
            deque._data[frontIndex] = value;
            deque._begin = frontIndex;
        }
    }

    /**
     * @dev Removes the item at the beginning of the queue and returns it.
     *
     * Reverts with `QueueEmpty` if the queue is empty.
     */
    function popFront(Uint256Deque storage deque) internal returns (uint256 value) {
        unchecked {
            uint128 frontIndex = deque._begin;
            if (frontIndex == deque._end) revert QueueEmpty();
            value = deque._data[frontIndex];
            delete deque._data[frontIndex];
            deque._begin = frontIndex + 1;
        }
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     *
     * Reverts with `QueueEmpty` if the queue is empty.
     */
    function front(Uint256Deque storage deque) internal view returns (uint256 value) {
        if (empty(deque)) revert QueueEmpty();
        return deque._data[deque._begin];
    }

    /**
     * @dev Returns the item at the end of the queue.
     *
     * Reverts with `QueueEmpty` if the queue is empty.
     */
    function back(Uint256Deque storage deque) internal view returns (uint256 value) {
        if (empty(deque)) revert QueueEmpty();
        unchecked {
            return deque._data[deque._end - 1];
        }
    }

    /**
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
     * `length(deque) - 1`.
     *
     * Reverts with `QueueOutOfBounds` if the index is out of bounds.
     */
    function at(Uint256Deque storage deque, uint256 index) internal view returns (uint256 value) {
        if (index >= length(deque)) revert QueueOutOfBounds();
        // By construction, length is a uint128, so the check above ensures that index can be safely downcast to uint128
        unchecked {
            return deque._data[deque._begin + uint128(index)];
        }
    }

    /**
     * @dev Resets the queue back to being empty.
     *
     * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
     * out on potential gas refunds.
     */
    function clear(Uint256Deque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    /**
     * @dev Returns the number of items in the queue.
     */
    function length(Uint256Deque storage deque) internal view returns (uint256) {
        unchecked {
            return uint256(deque._end - deque._begin);
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     */
    function empty(Uint256Deque storage deque) internal view returns (bool) {
        return deque._end == deque._begin;
    }
}
// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: MintDBTC/artifacts/MintDBTC/MintDBTC.sol


pragma solidity ^0.8.0;











contract MintDBTC is Ownable, ReentrancyGuard {
    using EnumerableMap for EnumerableMap.UintToUintMap;
    EnumerableMap.UintToUintMap private HashFEDay;
    EnumerableMap.UintToUintMap private TFEDay;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    EnumerableMap.AddressToUintMap private UserNCPower;
    EnumerableMap.AddressToUintMap private UserReceivesStartDate;
    EnumerableMap.AddressToUintMap private tokenPower;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableMap.AddressToUintMap private GiveawayUserNCPower;
    uint256 private constant MAX = ~uint256(0);
    using BitMaps for BitMaps.BitMap;
    mapping(address => BitMaps.BitMap) private UserReceiveRecord;
    BitMaps.BitMap private UBA;

    BitMaps.BitMap private tokenAllow;

    ISwapRouter public _Sr;

    address public usd;

    TokenDistributor public _tokenDistributor;
    TokenDBTCDistributor public _tokenDBTCDistributor;

    uint256 public _HashFactor = 1;
    uint256 public _LastUpdateTimestamp = 0;
    uint256 public _lastHashFactor = 0;

    uint256 public _ltp = 0;
    uint256 public _ltpTimestamp = 0;

    uint256 public _ds = 1 days;

    IERC20 public D;

    uint256 public _startDay;

    uint256 public _mea = 10 ether;

    uint256 public mintedDBTC = 0;

    ISwapFactory public swapFactory;

    address public _dead = 0x000000000000000000000000000000000000dEaD;

    address public _funderAddress;

    uint256 public _updateDays = 7;

    uint256 public _allPrice;

    uint256 public _drawDBTCFee;

    bool public _isDrawDBTCFee = false;

    uint256 public _MPI = 3000 ether;

    uint256 public _miP = 100 ether;

    mapping(address => uint256) public _UPI;

    uint256[] public _referReward = [12, 5, 3, 2, 2, 2, 1, 1, 1, 1];

    uint256 public _referLength = 9;

    bool public _startDrawDBTC = false;


    struct TInfoS {
        bool isBurn;
        bool isSwap;
        bool isToFunder;
        bool isSwapBurnDBTC;
        uint256 burnFee;
        uint256 swapFee;
        uint256 toFunder;
        uint256 _SBF;
        uint256 SlippageFee;
        address pair;
    }


    mapping(address => EnumerableSet.AddressSet) private _refersMap;
    mapping(address => EnumerableSet.AddressSet) private _refersGood;

    mapping(address => TInfoS) public tInfo;

    mapping(address => uint256) public _referAllPower;
    address public dp;

    mapping(uint256 => address) public _id_to_address;

    using Counters for Counters.Counter;
    Counters.Counter private _addressId;
    using DoubleEndedQueue for DoubleEndedQueue.Uint256Deque;
    struct ReferM {
        DoubleEndedQueue.Uint256Deque _referDeque;
        uint256 _referId;


    }

    mapping(address => uint256) public referPowerMap;

    mapping(address => ReferM) private _referMss;

    constructor() Ownable(msg.sender){
        _Sr = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usd = 0x55d398326f99059fF775485246999027B3197955;
        _tokenDistributor = new TokenDistributor(usd);
        dp = 0x21dfe97101717ed7f562da5D1Ccbceef8fef33c3;
        _funderAddress = 0x2f7689Ff67A1a77A39b912E923D6d4e7E40725Ae;
        _init();
        setHashFactorForEveryDay(getStartOfDayTimestamp(block.timestamp), 100);
        _lastHashFactor = 100;
        _startDay = getStartOfDayTimestamp(block.timestamp);
        swapFactory = ISwapFactory(_Sr.factory());
        mintedDBTC += _mea;
        uint256 d = getStartOfDayTimestamp(block.timestamp);
        setTotalNCPowerFromEveryDay(d, 0);
        _ltp = 0;
        _ltpTimestamp = d;
        _addressId.increment();
        _bindRefer(0xA9B3bC62fBE6393b4BB81db38e95D8Ab905C4A82, 0xA3d4e402749EaA81C30562FC3f30503Ea095ad0F);

    }

    function setDBTCAddress(address _dbtc) external onlyOwner {
        D = IERC20(_dbtc);
        _tokenDBTCDistributor = new TokenDBTCDistributor(address(D));
        D.approve(address(_Sr), MAX);
        setTokenFlag(address(D), true);
        tInfo[address(D)] = TInfoS(true, true, false, false, 50, 50, 0, 0, 0, address(0));
    }

    function _init() internal {
        address[7] memory tokens = [
                    0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c, // BTC
                    0x2170Ed0880ac9A755fd29B2688956BD959F933F8, // ETH
                    0x8fF795a6F4D97E7887C79beA79aba5cc76444aDf, // BCH
                    0x570A5D26f7765Ecb712C0924E4De545B89fD43dF, // SOL
                    0xbA2aE424d960c26247Dd6c32edC70B295c744C43, // DOGE
                    0x76A797A59Ba2C17726896976B7B3747BfD1d220f, // TON
                    0xD06B94a6Af942AC2EeFc4658f23b2C2E34131419  // MorningStar
            ];
        address[3] memory specialTokens = [dp, _Sr.WETH(), usd];
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).approve(address(_Sr), MAX);
            setTokenFlag(tokens[i], true);
            tInfo[tokens[i]] = TInfoS(true, true, false, false, 50, 50, 0, 0, 0, address(0));
        }

        for (uint256 i = 0; i < specialTokens.length; i++) {
            setTokenFlag(specialTokens[i], true);
            if (specialTokens[i] == usd || specialTokens[i] == _Sr.WETH()) {
                tInfo[specialTokens[i]] = TInfoS(false, true, true, true, 0, 50, 10, 40, 0, address(0));
            } else if (specialTokens[i] == dp) {
                tInfo[specialTokens[i]] = TInfoS(true, true, false, false, 50, 50, 0, 0, 0, address(0));
            }
        }
        tInfo[0xD06B94a6Af942AC2EeFc4658f23b2C2E34131419] = TInfoS(true, true, false, false, 50, 50, 0, 0, 5, 0x0440DE8cc081547dCD81505D40c0740DCe0f2388);
        IERC20(usd).approve(address(_Sr), MAX);
    }

    function _bindRefer(address u, address refer) internal {

        _id_to_address[_addressId.current()] = refer;
        _referMss[u]._referDeque.pushBack(_addressId.current());
        _referMss[u]._referId = _addressId.current();
        _addressId.increment();
        uint256 length = _referMss[refer]._referDeque.length();
        _refersMap[refer].add(u);
        length = length > _referLength ? _referLength : length;

        for (uint256 i = 0; i < length; i++) {
            _referMss[u]._referDeque.pushBack(_referMss[refer]._referDeque.at(i));
        }


    }

    function bindRefer(address refer) external {

        require(!hasRefer(msg.sender), "has refer");
        require(hasRefer(refer), "no refers");
        _bindRefer(msg.sender, refer);

    }

    function getRefers(address refer) public view returns (address[] memory){
        return _refersMap[refer].values();
    }

    function getRefersLength(address refer) public view returns (uint256){
        return _refersMap[refer].length();
    }

    function hasRefer(address u) public view returns (bool){
        if (_referMss[u]._referId == 0) {
            return false;
        }
        if (_referMss[u]._referDeque.front() == _referMss[u]._referId) {
            return true;
        }
        return false;
    }

    function getReferPower(address user) public view returns (uint256){
        return referPowerMap[user];
    }

    function getReferFirst(address user) public view returns (address){
        return _id_to_address[_referMss[user]._referDeque.front()];
    }


    function handleReferPower(address user, uint256 power) internal {
        uint256 length = _referMss[user]._referDeque.length();
        if (length == 0) {
            return;
        }

        for (uint256 i = 0; i < length && i < _referReward.length; i++) {
            address refer = _id_to_address[_referMss[user]._referDeque.at(i)];
            uint256 rl = _refersGood[refer].length();
            if (rl == 0 || rl < i + 1) {
                continue;
            }

            referPowerMap[refer] += power * _referReward[i] / 100;
        }
    }

    function drawDBTC() external nonReentrant returns (bool) {

        require(_startDrawDBTC, "Not start draw DBTC");

        require(!getUBA(msg.sender), "User is banned from drawing DBTC");

        IERC20 _c = IERC20(usd);
        uint256 balance = _c.balanceOf(address(this));
        if (balance > 0) {
            uint256 half = balance / 2;
            address[] memory path2 = new address[](2);
            path2[0] = usd;
            path2[1] = address(D);

            uint256 dbtcBalanceBefore = D.balanceOf(address(this));

            try
            _Sr.swapExactTokensForTokensSupportingFeeOnTransferTokens(half, 0, path2, address(_tokenDBTCDistributor), block.timestamp + 1000) {
            } catch {

                return false;
            }

            SafeERC20.safeTransferFrom(IERC20(D), address(_tokenDBTCDistributor), address(this), IERC20(D).balanceOf(address(_tokenDBTCDistributor)));
            uint256 dbtcBalanceAfter = D.balanceOf(address(this));
            uint256 dbtcReceived = dbtcBalanceAfter - dbtcBalanceBefore;

            try
            _Sr.addLiquidity(usd, address(D), half, dbtcReceived, 0, 0, _dead, block.timestamp + 2000) {
            } catch {

                return false;
            }
        }
        uint256 d = getStartOfDayTimestamp(block.timestamp);
        _drawDBTC(d);
        return true;
    }

    function _drawDBTC(uint256 d) internal {
        uint256 userNCPower = getUserNCPower(msg.sender);
        uint256 userReceiveStartDate = getUserReceivesStartDate(msg.sender);

        if (userNCPower == 0 || userReceiveStartDate == 0 || userReceiveStartDate > d) {
            return;
        }

        uint256 _dd = calculateOfDays(userReceiveStartDate, d);
        uint256 userReceiveDBTC = 0;

        _dd = _dd > _updateDays ? _updateDays : _dd;

        for (uint256 i = 0; i < _dd; i++) {
            uint256 currentDay = d - i * _ds;
            if (!getUserReceiveRecord(msg.sender, currentDay)) {
                uint256 totalNCPower = getTotalNCPowerFromEveryDay(currentDay);

                if (totalNCPower > 0) {
                    userReceiveDBTC += userNCPower * _mea / totalNCPower;
                    setUserReceiveRecord(msg.sender, currentDay);
                }
            }
        }

        setUserReceivesStartDate(msg.sender, d);

        if (referPowerMap[msg.sender] > 0) {
            UserNCPower.set(msg.sender, UserNCPower.get(msg.sender) + referPowerMap[msg.sender]);
            _referAllPower[msg.sender] += referPowerMap[msg.sender];
            referPowerMap[msg.sender] = 0;
        }

        if (userReceiveDBTC > 0) {
            if (_isDrawDBTCFee) {
                uint256 fee = userReceiveDBTC * _drawDBTCFee / 100;
                if (fee > 0 && userReceiveDBTC > fee) {
                    SafeERC20.safeTransfer(D, msg.sender, userReceiveDBTC - fee);
                    SafeERC20.safeTransfer(D, _funderAddress, fee);
                }
            } else {
                SafeERC20.safeTransfer(D, msg.sender, userReceiveDBTC);
            }
        }
    }


    function getUserCanMintDBTCAmount(address u) public view returns (uint256) {
        uint256 d = getStartOfDayTimestamp(block.timestamp);
        uint256 userNCPower = getUserNCPower(u);
        uint256 userReceiveStartDate = getUserReceivesStartDate(u);
        if (userReceiveStartDate >= d || userNCPower == 0 || userReceiveStartDate == 0) {
            return 0;
        }

        uint256 _dd = calculateOfDays(userReceiveStartDate, d);

        uint256 userReceiveDBTC = 0;
        _dd = _dd > _updateDays ? _updateDays : _dd;// 最多领取7天
        for (uint256 i = 0; i < _dd - 1; i++) {
            if (!getUserReceiveRecord(u, d - i * _ds)) {
                userReceiveDBTC += userNCPower * _mea / getTotalNCPowerFromEveryDay(d - i * _ds);
            }
        }

        if (!getUserReceiveRecord(u, d)) {
            uint256 s = block.timestamp - d;
            uint256 t = _mea / 86400 * s;
            userReceiveDBTC += userNCPower * t / getTotalNCPowerFromEveryDay(d);
        }


        return userReceiveDBTC;
    }

    function calculateStakingCoinsPower(IERC20 token, uint256 amount) public view returns (uint256) {
        uint256 d = getStartOfDayTimestamp(block.timestamp);
        uint256 hashFactor = getHashFactorForEveryDay(d);
        uint256 price = getPrice(token) * amount / 10 ** token.decimals();
        return price * hashFactor;
    }

    function getPrice(IERC20 token) public view returns (uint256 price) {

        if (address(token) == usd) {
            return 1 ether;
        }

        uint256 ds = 10 ** token.decimals();
        address pair = tInfo[address(token)].pair;

        if (pair == address(0)) {
            address _PA = swapFactory.getPair(address(token), usd);
            ISwapPair mainPair = ISwapPair(_PA);

            (uint256 reserve0, uint256 reserve1,) = mainPair.getReserves();

            if (mainPair.token0() == address(token)) {
                return reserve1 * ds / reserve0;
            } else {
                return reserve0 * ds / reserve1;
            }
        } else {

            (uint256 reserve01, uint256 reserve11,) = ISwapPair(pair).getReserves();

            uint256 price0 = 0;
            address _t0;

            if (ISwapPair(pair).token0() == address(token)) {
                price0 = reserve11 * ds / reserve01;
                _t0 = ISwapPair(pair).token1();
            } else {
                price0 = reserve01 * ds / reserve11;
                _t0 = ISwapPair(pair).token0();
            }

            address _PA = swapFactory.getPair(_t0, usd);
            ISwapPair mainPair = ISwapPair(_PA);

            (uint256 reserve0, uint256 reserve1,) = mainPair.getReserves();

            uint256 price2 = 0;

            if (mainPair.token0() == _t0) {
                price2 = reserve1 * 10 ** IERC20(_t0).decimals() / reserve0;
            } else {
                price2 = reserve0 * 10 ** IERC20(usd).decimals() / reserve1;
            }

            return price0 * price2 / 10 ** IERC20(_t0).decimals();
        }
    }


    function stakingCoins(IERC20 token, uint256 amount) external payable nonReentrant returns (bool){
        require(isTokenFlagSet(address(token)), "Token not allowed");
        require(amount > 0 || msg.value > 0, "Invalid amount");
        require(address(token) != address(0), "Invalid token address");
        uint256 ds = 10 ** token.decimals();

        if (msg.value > 0) {
            amount = msg.value;
        }
        uint256 _tp;
        if (address(token) == usd) {
            _tp = amount;

        } else {

            uint256 s = tInfo[address(token)].SlippageFee;
            if (s > 0) {
                uint256 price = getPrice(token);
                uint256 tAmount = amount * price / ds;
                uint256 slippage = price * s / 100;
                _tp = tAmount - slippage;
            } else {
                _tp = getPrice(token) * amount / ds;
            }

        }
        require(_UPI[msg.sender] + _tp <= _MPI, "Exceed the maximum amount");
        require(_tp >= _miP, "The minimum amount is 100 USDT");

        if (hasRefer(msg.sender)  && !_refersGood[getReferFirst(msg.sender)].contains(msg.sender)) {
            _refersGood[getReferFirst(msg.sender)].add(msg.sender);
        }
        _UPI[msg.sender] += _tp;

        _allPrice += _tp;


        if (address(token) == _Sr.WETH() && msg.value > 0) {
            address[] memory path = new address[](2);
            path[0] = _Sr.WETH();
            path[1] = usd;

            uint256 initialBalance = IERC20(usd).balanceOf(address(this));

            _Sr.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                0,
                path,
                address(_tokenDistributor),
                block.timestamp + 1000
            );

            SafeERC20.safeTransferFrom(IERC20(usd), address(_tokenDistributor), address(this), IERC20(usd).balanceOf(address(_tokenDistributor)));

            uint256 _ua = IERC20(usd).balanceOf(address(this)) - initialBalance;

            if (IERC20(usd).balanceOf(address(this)) == 0) {
                return false;
            }


            _handleToken(address(usd), _ua);
        } else {
            SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);
            _handleToken(address(token), amount);
        }

        // 继续处理 staking 逻辑
        uint256 d = getStartOfDayTimestamp(block.timestamp);
        if (!hasHashFactorForEveryDay(d)) {
            _updateHashFactor();
        }

        uint256 hashFactor = getHashFactorForEveryDay(d);
        uint256 userNCPower = 0;

        if (hasUserNCPower(msg.sender)) {
            userNCPower = getUserNCPower(msg.sender);
        }


        if (hasUserReceivesStartDate(msg.sender)) {
            if (getUserReceivesStartDate(msg.sender) < d) {
                _drawDBTC(d);
            }
        } else {
            setUserReceivesStartDate(msg.sender, d);
        }

        _tp = _tp * hashFactor;

        userNCPower += _tp;

        _ltp += _tp;

        _ltpTimestamp = d;

        setTotalNCPowerFromEveryDay(d, _ltp);
        setUserNCPower(msg.sender, userNCPower);

        if (hasRefer(msg.sender)) {
            handleReferPower(msg.sender, _tp);
        }
        setTokenPower(address(token), getTokenPower(address(token)) + _tp);
        _updateMintDBTC();
        return true;

    }


    function _handleToken(address _t, uint256 amount) internal {
        uint256 burnFee;
        uint256 toFunderFee;
        uint256 _SBF;
        TInfoS memory info = tInfo[_t];

        if (info.isSwapBurnDBTC) {
            _SBF = amount * info._SBF / 100;

            if (_t == address(usd)) {
                address[] memory path = new address[](2);
                path[0] = usd;
                path[1] = address(D);
                _swapToDead(path, _SBF);
            } else if (info.pair != address(0) && _t != address(usd)) {
                address[] memory path = new address[](4);
                path[0] = _t;
                path[1] = getToken0(info.pair, _t);
                path[2] = usd;
                path[3] = address(D);
                _swapToDead(path, _SBF);
            } else if (info.pair == address(0) && _t != address(usd)) {
                address[] memory path = new address[](3);
                path[0] = _t;
                path[1] = usd;
                path[2] = address(D);
                _swapToDead(path, _SBF);
            }

        }

        if (info.isBurn) {
            burnFee = amount * info.burnFee / 100;
            SafeERC20.safeTransfer(IERC20(_t), _dead, burnFee);
        }
        if (info.isSwap) {
            if (_t != address(usd) && info.pair == address(0)) {
                address[] memory path = new address[](2);
                path[0] = _t;
                path[1] = usd;
                _swap(path, amount, info.swapFee);
            } else if (_t != address(usd) && info.pair != address(0)) {
                address[] memory path = new address[](3);
                path[0] = _t;
                path[1] = getToken0(info.pair, _t);
                path[2] = usd;
                _swap(path, amount, info.swapFee);
            }


        }
        if (info.isToFunder) {
            toFunderFee = amount * info.toFunder / 100;
            SafeERC20.safeTransfer(IERC20(_t), _funderAddress, toFunderFee);

        }

    }

    function _swap(address[] memory path, uint256 amount, uint256 swapFe) internal {
        swapFe = amount * swapFe / 100;
        _Sr.swapExactTokensForTokensSupportingFeeOnTransferTokens(swapFe, 0, path, address(_tokenDistributor), block.timestamp + 1000);
        SafeERC20.safeTransferFrom(IERC20(usd), address(_tokenDistributor), address(this), IERC20(usd).balanceOf(address(_tokenDistributor)));
    }

    function _swapToDead(address[] memory path, uint256 _SBF) internal {
        _Sr.swapExactTokensForTokensSupportingFeeOnTransferTokens(_SBF, 0, path, _dead, block.timestamp + 1000);
    }

    function getToken0(address _pair, address _t) public view returns (address){
        if (ISwapPair(_pair).token0() == _t) {
            return ISwapPair(_pair).token1();
        } else {
            return ISwapPair(_pair).token0();
        }
    }

    function _updateHashFactor() internal {
        uint256 d = getStartOfDayTimestamp(block.timestamp);

        if (_LastUpdateTimestamp == 0) {
            _LastUpdateTimestamp = d;
        }

        if (d != _LastUpdateTimestamp) {
            uint256 hashFactor = getHashFactorForEveryDay(_LastUpdateTimestamp);
            hashFactor += _HashFactor;
            setHashFactorForEveryDay(d, hashFactor);
            _LastUpdateTimestamp = d;
            _lastHashFactor = hashFactor;
        }
    }

    function updateHashFactor() external onlyOwner {
        _updateHashFactor();
    }

    function set_startDrawDBTC(bool _fff) external onlyOwner {
        _startDrawDBTC = _fff;
    }


    function updateTotalNCPower() external onlyOwner {
        uint256 _ctt = block.timestamp;
        uint256 _dd = calculateOfDays(_ltpTimestamp, _ctt);
        uint256 d = getStartOfDayTimestamp(_ctt);

        uint256 totalNCPower = HasTotalNCPowerFromEveryDay(_ltpTimestamp)
            ? getTotalNCPowerFromEveryDay(_ltpTimestamp)
            : _ltp;

        _dd = _dd > _updateDays ? _updateDays : _dd;

        for (uint256 i = 0; i < _dd; i++) {
            setTotalNCPowerFromEveryDay(d - i * _ds, totalNCPower);
        }

        _ltpTimestamp = _ctt;
        _ltp = totalNCPower;
    }

    function getTotalMintDBTC() public view returns (uint256) {
        uint256 _ctt = block.timestamp;
        uint256 _dd = calculateOfDays(_startDay, _ctt);
        uint256 totalMintDBTC = 0;
        totalMintDBTC = _mea * _dd;
        return totalMintDBTC + mintedDBTC;
    }

    function _updateMintDBTC() internal {
        uint256 _ctt = block.timestamp;
        uint256 _dd = calculateOfDays(_startDay, _ctt);
        if (_dd == 0) {
            return;
        }

        uint256 mintDBTC;

        mintDBTC = _mea * _dd;

        mintedDBTC += mintDBTC;
        _startDay = _startDay + _dd * _ds;
    }

    function updateMintDBTC() external {
        _updateMintDBTC();
    }

    function isTokenFlagSet(address _t) public view returns (bool) {
        uint256 index = uint256(uint160(_t));
        return tokenAllow.get(index);
    }

    function setTokenFlag(address _t, bool value) internal {
        uint256 index = uint256(uint160(_t));
        tokenAllow.setTo(index, value);
        IERC20(_t).approve(address(_Sr), MAX);

    }

    function setTokenPower(address _t, uint256 power) internal {
        tokenPower.set(_t, power);
    }

    function getTokenPower(address _t) public view returns (uint256) {
        if (hasTokenPower(_t)) {
            return tokenPower.get(_t);
        } else {
            return 0;
        }
    }

    function hasTokenPower(address _t) public view returns (bool) {
        return tokenPower.contains(_t);
    }

    function getTokenPowerByAllPowerPercent(address _t) public view returns (uint256) {

        if (hasTokenPower(_t) && _ltp > 0) {
            uint256 _tokenPower = tokenPower.get(_t);
            uint256 totalNCPower = _ltp;
            return _tokenPower * 100 / totalNCPower;
        } else
        {
            return 0;
        }

    }


    function setUserReceivesStartDate(address user, uint256 startDate) internal {
        UserReceivesStartDate.set(user, startDate);
    }

    function getUserReceivesStartDate(address user) public view returns (uint256) {
        if (hasUserReceivesStartDate(user)) {
            return UserReceivesStartDate.get(user);
        } else {
            return 0;
        }
    }

    function hasUserReceivesStartDate(address user) public view returns (bool) {
        return UserReceivesStartDate.contains(user);
    }

    function getGiveawayUserNCPower(address user) public view returns (uint256) {
        if (hasGiveawayUserNCPower(user)) {
            return GiveawayUserNCPower.get(user);
        } else {
            return 0;
        }
    }

    function removeGiveawayUserNCPower(address user) external onlyOwner {
        uint256 d = getStartOfDayTimestamp(block.timestamp);
        uint256 totalPower = getTotalNCPowerFromEveryDay(d);
        totalPower -= getGiveawayUserNCPower(user);
        setTotalNCPowerFromEveryDay(d, totalPower);
        _ltpTimestamp = d;
        _ltp = totalPower;
        setUserNCPower(user, getUserNCPower(user) - getGiveawayUserNCPower(user));
        GiveawayUserNCPower.remove(user);

    }

    function hasGiveawayUserNCPower(address user) public view returns (bool) {
        return GiveawayUserNCPower.contains(user);
    }

    function setUserReceiveRecord(address user, uint256 d) internal {
        BitMaps.BitMap storage attendanceRecord = UserReceiveRecord[user];
        require(!attendanceRecord.get(d), "Already Receive in for the d");
        UserReceiveRecord[user].set(d);
    }

    function getUserReceiveRecord(address user, uint256 d) public view returns (bool) {
        return UserReceiveRecord[user].get(d);
    }

    function setHashFactorForEveryDay(uint256 d, uint256 hashFactor) internal {
        HashFEDay.set(d, hashFactor);
    }

    function hasHashFactorForEveryDay(uint256 d) public view returns (bool) {
        return HashFEDay.contains(d);
    }

    function getHashFactorForEveryDay(uint256 d) public view returns (uint256) {
        if (hasHashFactorForEveryDay(d)) {
            return HashFEDay.get(d);
        } else {
            return _lastHashFactor;
        }
    }

    function HasTotalNCPowerFromEveryDay(uint256 d) public view returns (bool) {
        return TFEDay.contains(d);
    }

    function setTotalNCPowerFromEveryDay(uint256 d, uint256 totalNCPower) internal {
        TFEDay.set(d, totalNCPower);
    }

    function getTotalNCPowerFromEveryDay(uint256 d) public view returns (uint256) {
        if (HasTotalNCPowerFromEveryDay(d)) {
            return TFEDay.get(d);
        } else {
            return _ltp;
        }
    }

    function setUserNCPower(address user, uint256 ncPower) internal {
        UserNCPower.set(user, ncPower);
    }

    function getUserNCPower(address user) public view returns (uint256) {
        if (hasUserNCPower(user)) {
            return UserNCPower.get(user);
        } else {
            return 0;
        }
    }

    function hasUserNCPower(address user) public view returns (bool) {
        return UserNCPower.contains(user);
    }

    function setTInfoS(address _t, bool isBurn, bool isSwap, bool isToFunder, bool isSwapBurnDBTC, uint256 burnFee, uint256 swapFee, uint256 toFunder, uint256 _SBF, uint256 SlippageFee, address pair) external onlyOwner {
        require(_t != address(0), "Token zero");
        require(burnFee + swapFee + toFunder + _SBF <= 100, "Invalid fee");
        tInfo[_t] = TInfoS(isBurn, isSwap, isToFunder, isSwapBurnDBTC, burnFee, swapFee, toFunder, _SBF, SlippageFee, pair);
    }

    function getTInfoS(address _t) public view returns (TInfoS memory) {
        return tInfo[_t];
    }


    function calculateOfDays(uint256 startTimestamp, uint256 endTimestamp) public view returns (uint256) {
        uint256 secondsPerDay = _ds;
        if (endTimestamp <= startTimestamp) {
            return 0;
        }
        uint256 _dd = (endTimestamp - startTimestamp) / secondsPerDay;
        return _dd;
    }

    function getStartOfDayTimestamp(uint256 timestamp) public view returns (uint256) {

        uint256 secondsPerDay = _ds;
        uint256 _dd = timestamp / secondsPerDay;
        uint256 startOfDayTimestamp = _dd * secondsPerDay;
        return startOfDayTimestamp;
    }

    function Claims(address _t, uint256 amount) external onlyOwner {
        if (_t == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(!isTokenFlagSet(_t), "Token not allowed");
            IERC20(_t).transfer(msg.sender, amount);
        }
    }

    receive() external payable {}

    function setSystemParameters(
        uint256 hashFactor,
        uint256 lastUpdateTimestamp,
        uint256 lastHashFactor,
        uint256 lastTotalNCPower,
        uint256 lastTotalNCPowerTimestamp,
        uint256 startDay
    ) external onlyOwner {
        _HashFactor = hashFactor;
        _LastUpdateTimestamp = lastUpdateTimestamp;
        _lastHashFactor = lastHashFactor;
        _ltp = lastTotalNCPower;
        _ltpTimestamp = lastTotalNCPowerTimestamp;
        _startDay = startDay;
    }

    function setNCPowerAndRecords(
        uint256 d,
        uint256 totalNCPower,
        address user,
        uint256 startDate,
        uint256 ncPower,
        uint256 _tokenPower
    ) external onlyOwner {
        TFEDay.set(d, totalNCPower);
        UserReceivesStartDate.set(user, startDate);
        UserNCPower.set(user, ncPower);
        tokenPower.set(user, _tokenPower);
    }

    function setUserDetails(
        address user,
        uint256 d,
        uint256 ncPower,
        uint256 startDate
    ) external onlyOwner {
        require(!UserReceiveRecord[user].get(d), "Already Receive in for the d");
        UserReceiveRecord[user].set(d);
        UserReceivesStartDate.set(user, startDate);
        UserNCPower.set(user, ncPower);
    }

    function setTokenDetails(
        address token,
        uint256 power
    ) external onlyOwner {
        tokenPower.set(token, power);
    }


    function setGUPA(address[] memory users, uint256[] memory powers) external onlyOwner {
        require(users.length == powers.length, "Users and powers array length must match");
        uint256 d = getStartOfDayTimestamp(block.timestamp);
        uint256 totalPower = getTotalNCPowerFromEveryDay(d);

        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 power = powers[i];

            totalPower += power;

            if (hasRefer(user) && !_refersGood[getReferFirst(user)].contains(user)) {
                _refersGood[getReferFirst(user)].add(user);
            }

            setUserNCPower(user, getUserNCPower(user) + power);
            GiveawayUserNCPower.set(user, getGiveawayUserNCPower(user) + power);
        }

        setTotalNCPowerFromEveryDay(d, totalPower);
        _ltpTimestamp = d;
        _ltp = totalPower;
    }

    function get_allPrice() public view returns (uint256) {
        return _allPrice;
    }


    function get_referAllPower(address refer) public view returns (uint256){
        return _referAllPower[refer];
    }


    function setTFlag(address _t, bool value) external onlyOwner {
        uint256 index = uint256(uint160(_t));
        tokenAllow.setTo(index, value);
    }

    function set_miP(uint256 _mi) external onlyOwner {
        _miP = _mi;
    }


    function set_DF(uint256 _fee, bool _isFee) external onlyOwner {
        _drawDBTCFee = _fee;
        _isDrawDBTCFee = _isFee;
    }

    function set_MPI(uint256 _maxPrice) external onlyOwner {
        _MPI = _maxPrice;
    }

    function set_UPI(address user, uint256 price) external onlyOwner {
        _UPI[user] = price;
    }

    function setUBA(address user, bool value) external onlyOwner {
        uint256 index = uint256(uint160(user));
        UBA.setTo(index, value);
    }

    function getUBA(address user) public view returns (bool) {
        uint256 index = uint256(uint160(user));
        return UBA.get(index);
    }

    function getReferLength(address refer) public view returns (uint256) {
        return _referMss[refer]._referDeque.length();
    }

    function getRefersGoodLength(address refer) public view returns (uint256) {
        return _refersGood[refer].length();
    }

    function getReferAt(address refer, uint256 index) public view returns (address) {
        return _id_to_address[_referMss[refer]._referDeque.at(index)];
    }


    function getReferDeque(address refer) public view returns (address[] memory) {
        uint256 length = _referMss[refer]._referDeque.length();
        address[] memory referArray = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            referArray[i] = _id_to_address[_referMss[refer]._referDeque.at(i)];
        }
        return referArray;
    }

    function getReferId(address refer) public view returns (uint256) {
        return _referMss[refer]._referId;
    }

    function set_ds(uint256 _dss) external onlyOwner {
        _ds = _dss;
    }

}

contract TokenDistributor {
    constructor(address _t) {
        IERC20(_t).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract TokenDBTCDistributor {
    constructor(address _t) {
        IERC20(_t).approve(msg.sender, uint256(~uint256(0)));
    }
}
