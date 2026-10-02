#pragma once

#include <vector>

#include <QAbstractListModel>
#include <QString>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

// Mock card collection for the Collections page. Filtering and shuffling emit fine-grained
// insert/remove/move signals so the view can animate each change.
class CollectionModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("CollectionModel is created by the application.")

    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY categoryChanged)
    Q_PROPERTY(QStringList categories READ categories CONSTANT)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role
    {
        TitleRole = Qt::UserRole + 1,
        SubtitleRole,
        CategoryRole,
        IconNameRole,
        SizeLabelRole,
        FillRole,
        HueRole
    };

    struct Entry
    {
        QString title;
        QString subtitle;
        QString category;
        QString iconName;
        double sizeGigabytes = 0.0;
        double fill = 0.0; // 0..1, drives the small meter on each card
        int hue = 0;       // 0..359, tints the card icon
    };

    static inline const QString kAllCategories = QStringLiteral("All");

    explicit CollectionModel(QObject *parent = nullptr);

    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;
    [[nodiscard]] QHash<int, QByteArray> roleNames() const override;

    [[nodiscard]] QString category() const { return m_category; }
    void setCategory(const QString &category);
    [[nodiscard]] QStringList categories() const;

    Q_INVOKABLE void shuffle();

    // Test access: the title shown in each visible row.
    [[nodiscard]] QStringList visibleTitles() const;

signals:
    void categoryChanged();
    void countChanged();

private:
    [[nodiscard]] bool matchesCategory(int entryIndex) const;
    [[nodiscard]] std::vector<int> wantedRows() const;
    void syncVisibleRows();

    std::vector<Entry> m_entries;
    // Indices into m_entries, in display order. Always ordered the same way as m_entries.
    std::vector<int> m_visibleRows;
    QString m_category = kAllCategories;
};
