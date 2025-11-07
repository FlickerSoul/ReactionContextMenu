//
//  ContextMenuAppearingSide.swift
//
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

public enum ContextMenuAppearingSide {
    case leading
    case trailing

    var alignment: Alignment {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    var edge: Edge {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    var edgeSet: Edge.Set {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    var unitPoint: UnitPoint {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}
