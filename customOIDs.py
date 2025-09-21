#!/usr/bin/env python3

# Python script to generate PIV object OIDs in the range 5f0000 to 5fffff

# Total Possible OIDs 65536

# Start and end OIDs
start_oid = 0x5f0000
end_oid = 0x5fffff

# Loop through the range and print each OID
for oid in range(start_oid, end_oid + 1):
    # Format the OID as hexadecimal, ensuring it's 6 digits long (with leading zeroes)
    print(f"0x{oid:06x}")
