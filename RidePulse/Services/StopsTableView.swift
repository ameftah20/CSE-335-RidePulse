//
//  StopsTableView.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import SwiftUI
import UIKit

struct StopsTableView: UIViewRepresentable {
    let stops: [StopDTO]
    let onSelect: (StopDTO) -> Void

    func makeUIView(context: Context) -> UITableView {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = context.coordinator
        table.delegate = context.coordinator
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        context.coordinator.stops = stops
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var stops: [StopDTO] = []
        let onSelect: (StopDTO) -> Void

        init(onSelect: @escaping (StopDTO) -> Void) {
            self.onSelect = onSelect
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            stops.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let stop = stops[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = stop.name
            content.secondaryText = "ID: \(stop.id)"
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            onSelect(stops[indexPath.row])
        }
    }
}
