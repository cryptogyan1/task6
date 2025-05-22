from eth_account import Account
import os

# Enable HD wallet features
Account.enable_unaudited_hdwallet_features()

def generate_hd_wallets(num_wallets=1):
    addresses_only = []
    full_wallet_info = []

    for i in range(num_wallets):
        entropy = os.urandom(16)  # 128-bit entropy for 12-word mnemonic
        mnemonic = Account.mnemonic_from_entropy(entropy)
        account = Account.from_mnemonic(mnemonic)

        wallet_number = f"Wallet {i + 1}"
        address = account.address
        private_key = account.key.hex()

        addresses_only.append(f"{wallet_number}: {address}")
        full_wallet_info.append(
            f"{wallet_number}\nMnemonic: {mnemonic}\nPrivate Key: {private_key}\nAddress: {address}\n{'='*40}"
        )

    # Save all addresses to a file
    with open("addresses.txt", "w") as addr_file:
        addr_file.write("\n".join(addresses_only))

    # Save full wallet details to a file
    with open("wallet_details.txt", "w") as detail_file:
        detail_file.write("\n\n".join(full_wallet_info))

    return addresses_only, full_wallet_info

def display_menu():
    print("\n===== Secure Ethereum HD Wallet Generator =====")
    print("1. Generate HD Wallets (Mnemonic-based)")
    print("2. Exit")
    return input("Enter your choice (1-2): ")

def main():
    while True:
        choice = display_menu()

        if choice == '1':
            try:
                num_wallets = int(input("How many HD wallets would you like to generate? "))
                generate_hd_wallets(num_wallets)
                print(f"\nSuccessfully generated {num_wallets} HD wallets.")
                print("Addresses saved to: addresses.txt")
                print("Wallet details saved to: wallet_details.txt")
            except ValueError:
                print("Please enter a valid number.")
            except Exception as e:
                print(f"An error occurred: {str(e)}")

        elif choice == '2':
            print("Exiting the program. Goodbye!")
            break

        else:
            print("Invalid choice. Please select a number between 1 and 2.")

if __name__ == '__main__':
    main()
