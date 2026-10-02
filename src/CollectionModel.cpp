#include "CollectionModel.h"

#include <algorithm>
#include <iterator>

#include <QLocale>
#include <QRandomGenerator>

namespace {

std::vector<CollectionModel::Entry> createEntries()
{
    return {
        {QObject::tr("Photo Library"), QObject::tr("12,480 items"), QStringLiteral("Media"),
         QStringLiteral("image"), 48.2, 0.72, 280},
        {QObject::tr("Music"), QObject::tr("3,215 tracks"), QStringLiteral("Media"),
         QStringLiteral("musicNotes"), 21.7, 0.41, 330},
        {QObject::tr("Screen Recordings"), QObject::tr("86 clips"), QStringLiteral("Media"),
         QStringLiteral("filmStrip"), 37.9, 0.64, 200},
        {QObject::tr("Podcasts"), QObject::tr("142 episodes"), QStringLiteral("Media"),
         QStringLiteral("waveform"), 9.4, 0.22, 20},
        {QObject::tr("Atlas Redesign"), QObject::tr("Updated today"), QStringLiteral("Projects"),
         QStringLiteral("compass"), 6.3, 0.83, 170},
        {QObject::tr("Orbit Engine"), QObject::tr("Updated 2 days ago"), QStringLiteral("Projects"),
         QStringLiteral("atom"), 14.8, 0.57, 250},
        {QObject::tr("Field Notes"), QObject::tr("Updated last week"), QStringLiteral("Projects"),
         QStringLiteral("bookOpen"), 0.9, 0.18, 45},
        {QObject::tr("Greenhouse"), QObject::tr("Updated yesterday"), QStringLiteral("Projects"),
         QStringLiteral("leaf"), 3.1, 0.36, 130},
        {QObject::tr("Prototype Lab"), QObject::tr("Updated 3 hours ago"),
         QStringLiteral("Projects"), QStringLiteral("flask"), 2.4, 0.49, 300},
        {QObject::tr("System Caches"), QObject::tr("Rebuilt automatically"),
         QStringLiteral("System"), QStringLiteral("cpu"), 11.6, 0.68, 210},
        {QObject::tr("Archives"), QObject::tr("Cold storage"), QStringLiteral("System"),
         QStringLiteral("hardDrives"), 92.5, 0.91, 190},
        {QObject::tr("Security Keys"), QObject::tr("4 devices"), QStringLiteral("System"),
         QStringLiteral("shieldCheck"), 0.1, 0.12, 150},
    };
}

} // namespace

CollectionModel::CollectionModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_entries(createEntries())
{
    // Assigned here, not in the initializer list: wantedRows() reads m_category, which is
    // declared after m_visibleRows.
    m_visibleRows = wantedRows();
}

int CollectionModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return static_cast<int>(m_visibleRows.size());
}

QVariant CollectionModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid)) {
        return {};
    }
    const Entry &entry = m_entries.at(m_visibleRows.at(static_cast<size_t>(index.row())));
    switch (role) {
    case TitleRole:
        return entry.title;
    case SubtitleRole:
        return entry.subtitle;
    case CategoryRole:
        return entry.category;
    case IconNameRole:
        return entry.iconName;
    case SizeLabelRole:
        return tr("%1 GB").arg(QLocale().toString(entry.sizeGigabytes, 'f', 1));
    case FillRole:
        return entry.fill;
    case HueRole:
        return entry.hue;
    default:
        return {};
    }
}

QHash<int, QByteArray> CollectionModel::roleNames() const
{
    return {
        {TitleRole, "title"},       {SubtitleRole, "subtitle"},   {CategoryRole, "category"},
        {IconNameRole, "iconName"}, {SizeLabelRole, "sizeLabel"}, {FillRole, "fill"},
        {HueRole, "hue"},
    };
}

void CollectionModel::setCategory(const QString &category)
{
    if (m_category == category || !categories().contains(category)) {
        return;
    }
    m_category = category;
    emit categoryChanged();
    syncVisibleRows();
}

QStringList CollectionModel::categories() const
{
    return {kAllCategories, QStringLiteral("Media"), QStringLiteral("Projects"),
            QStringLiteral("System")};
}

void CollectionModel::shuffle()
{
    std::vector<int> order(m_entries.size());
    for (size_t i = 0; i < order.size(); ++i) {
        order[i] = static_cast<int>(i);
    }
    std::shuffle(order.begin(), order.end(), *QRandomGenerator::global());

    std::vector<Entry> shuffled;
    shuffled.reserve(m_entries.size());
    std::vector<int> newIndexOf(m_entries.size());
    for (size_t position = 0; position < order.size(); ++position) {
        const auto oldIndex = static_cast<size_t>(order[position]);
        shuffled.push_back(m_entries[oldIndex]);
        newIndexOf[oldIndex] = static_cast<int>(position);
    }
    m_entries = std::move(shuffled);

    // Rename visible rows to the new entry indices, then move rows one by one into the new
    // order so the view sees individual moves it can animate.
    for (int &entryIndex : m_visibleRows) {
        entryIndex = newIndexOf[static_cast<size_t>(entryIndex)];
    }
    const std::vector<int> target = wantedRows();
    for (size_t row = 0; row < target.size(); ++row) {
        const auto found = std::find(m_visibleRows.begin() + static_cast<std::ptrdiff_t>(row),
                                     m_visibleRows.end(), target[row]);
        const auto from = static_cast<int>(std::distance(m_visibleRows.begin(), found));
        const auto to = static_cast<int>(row);
        if (from == to) {
            continue;
        }
        beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);
        const int moved = *found;
        m_visibleRows.erase(found);
        m_visibleRows.insert(m_visibleRows.begin() + to, moved);
        endMoveRows();
    }
}

QStringList CollectionModel::visibleTitles() const
{
    QStringList titles;
    for (const int entryIndex : m_visibleRows) {
        titles.append(m_entries.at(static_cast<size_t>(entryIndex)).title);
    }
    return titles;
}

bool CollectionModel::matchesCategory(int entryIndex) const
{
    return m_category == kAllCategories ||
           m_entries.at(static_cast<size_t>(entryIndex)).category == m_category;
}

std::vector<int> CollectionModel::wantedRows() const
{
    std::vector<int> rows;
    for (size_t i = 0; i < m_entries.size(); ++i) {
        if (matchesCategory(static_cast<int>(i))) {
            rows.push_back(static_cast<int>(i));
        }
    }
    return rows;
}

void CollectionModel::syncVisibleRows()
{
    const int previousCount = rowCount();

    // Both lists follow m_entries order, so removing unwanted rows and then inserting the
    // missing ones in order turns the old list into the new one.
    for (int row = rowCount() - 1; row >= 0; --row) {
        if (!matchesCategory(m_visibleRows[static_cast<size_t>(row)])) {
            beginRemoveRows(QModelIndex(), row, row);
            m_visibleRows.erase(m_visibleRows.begin() + row);
            endRemoveRows();
        }
    }

    const std::vector<int> target = wantedRows();
    for (size_t row = 0; row < target.size(); ++row) {
        if (row < m_visibleRows.size() && m_visibleRows[row] == target[row]) {
            continue;
        }
        const auto position = static_cast<int>(row);
        beginInsertRows(QModelIndex(), position, position);
        m_visibleRows.insert(m_visibleRows.begin() + position, target[row]);
        endInsertRows();
    }

    if (rowCount() != previousCount) {
        emit countChanged();
    }
}
