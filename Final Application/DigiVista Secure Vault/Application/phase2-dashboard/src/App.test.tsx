import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import App from "./App";

describe("DigiVista dashboard", () => {
  it("shows professional categories by default", () => {
    render(<App />);
    expect(screen.getByText("Network Devices")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Administration" })).toHaveAttribute("href", "/#/organizations");
    expect(screen.getByRole("link", { name: "Secure vault" })).toHaveAttribute("href", "/?dv=stay#/vault");
  });

  it("shows only family categories and removes administration", () => {
    render(<App />);
    fireEvent.change(screen.getByLabelText("Experience"), { target: { value: "family" } });
    expect(screen.getByText("Games & Apps")).toBeInTheDocument();
    expect(screen.queryByText("Network Devices")).not.toBeInTheDocument();
    expect(screen.queryByRole("link", { name: "Administration" })).not.toBeInTheDocument();
  });

  it("opens a guided secure template", () => {
    render(<App />);
    fireEvent.click(screen.getByRole("button", { name: /Network Devices/ }));
    expect(screen.getByRole("heading", { level: 2, name: "Network Devices" })).toBeInTheDocument();
    expect(screen.getByText("Management IP")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Continue in secure vault/ })).toHaveAttribute("href", expect.stringContaining("type=login"));
    expect(screen.getByRole("link", { name: /Continue in secure vault/ })).toHaveAttribute("href", expect.stringMatching(/^\/\?dv=action&dvFolder=Network%20Devices#\/vault/));
  });

  it("keeps the security and help links on the same trusted origin", () => {
    render(<App />);
    expect(screen.getByRole("link", { name: "Security health" })).toHaveAttribute("href", "/#/reports");
    expect(screen.getByRole("link", { name: "Help & recovery" })).toHaveAttribute("href", "/help");
    expect(screen.getByRole("link", { name: "Trust & policies" })).toHaveAttribute("href", "/dashboard/trust.html");
  });

  it("shows a private journal for home users without business administration", () => {
    render(<App />);
    fireEvent.change(screen.getByLabelText("Experience"), { target: { value: "home" } });
    expect(screen.getByText("Private Journal & Goals")).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: "Administration" })).not.toBeInTheDocument();
    expect(screen.queryByText("Network Devices")).not.toBeInTheDocument();
  });

  it("keeps teen private categories separate from professional infrastructure", () => {
    render(<App />);
    fireEvent.change(screen.getByLabelText("Experience"), { target: { value: "teen" } });
    expect(screen.getByText("Social & Apps")).toBeInTheDocument();
    expect(screen.getByText("Private Journal & Goals")).toBeInTheDocument();
    expect(screen.queryByText("Servers & Infrastructure")).not.toBeInTheDocument();
  });
});
