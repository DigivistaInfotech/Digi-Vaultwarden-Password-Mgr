import { describe, expect, it } from "vitest";
import { permissionPolicies, validatePermissionBoundary } from "./permissions";

describe("role and privacy policy", () => {
  it("never allows any role to view another user's personal vault", () => {
    expect(Object.keys(permissionPolicies).every(role => validatePermissionBoundary(role as keyof typeof permissionPolicies))).toBe(true);
  });

  it("limits organization management to the owner", () => {
    expect(permissionPolicies.owner.canManageOrganization).toBe(true);
    expect(Object.entries(permissionPolicies).filter(([role]) => role !== "owner").every(([, policy]) => !policy.canManageOrganization)).toBe(true);
  });

  it("allows only owner and admin to manage members", () => {
    expect(Object.entries(permissionPolicies).filter(([, policy]) => policy.canManageMembers).map(([role]) => role)).toEqual(["owner", "admin"]);
  });

  it("keeps home and teen users outside organization collections", () => {
    expect(permissionPolicies.home.canViewAssignedCollections).toBe(false);
    expect(permissionPolicies.teen.canViewAssignedCollections).toBe(false);
  });

  it("maps each non-business experience to its restricted dashboard", () => {
    expect(permissionPolicies.home.dashboardMode).toBe("home");
    expect(permissionPolicies.teen.dashboardMode).toBe("teen");
    expect(permissionPolicies.family.dashboardMode).toBe("family");
  });
});
