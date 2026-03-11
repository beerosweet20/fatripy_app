"""Set or clear Firebase custom admin claim for a user.

Usage:
  python set_admin_claim.py --cred path/to/service-account.json --email admin@example.com --admin true
  python set_admin_claim.py --cred path/to/service-account.json --uid <uid> --admin false
"""

import argparse
import firebase_admin
from firebase_admin import auth, credentials


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Set Firebase custom admin claim")
    parser.add_argument("--cred", required=True, help="Service account JSON file path")
    parser.add_argument("--uid", help="Firebase Auth UID")
    parser.add_argument("--email", help="Firebase Auth email")
    parser.add_argument(
        "--admin",
        required=True,
        choices=["true", "false"],
        help="Whether to enable admin claim",
    )
    args = parser.parse_args()
    if not args.uid and not args.email:
        parser.error("Provide either --uid or --email")
    return args


def main() -> None:
    args = _parse_args()
    cred = credentials.Certificate(args.cred)
    firebase_admin.initialize_app(cred)

    user = auth.get_user(args.uid) if args.uid else auth.get_user_by_email(args.email)
    admin_enabled = args.admin.lower() == "true"

    claims = dict(user.custom_claims or {})
    claims["admin"] = admin_enabled
    auth.set_custom_user_claims(user.uid, claims)

    print(
        f"Updated claims for uid={user.uid}, email={user.email}: "
        f"admin={admin_enabled}"
    )


if __name__ == "__main__":
    main()
