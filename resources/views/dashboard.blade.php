@extends('layout')

@section('content')
<div class="container mt-4">
    <div class="alert alert-primary d-flex justify-content-between align-items-center" role="alert">
        <div>
            Selamat datang, <strong>{{ Auth::user()->name }}</strong> ({{ Auth::user()->role }})
        </div>
    </div>

    @if($stokHampirHabis->isNotEmpty())
        <div class="row mt-4">
            <div class="col-12">
                <div class="alert alert-warning">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h4 class="alert-heading"><i class="fas fa-exclamation-triangle me-2"></i>Peringatan Stok Rendah!</h4>
                            <p class="mb-0">Terdapat <strong>{{ $stokHampirHabis->count() }}</strong> barang dengan stok di bawah batas minimal. Harap segera lakukan pengadaan ulang.</p>
                        </div>
                        <button class="btn btn-sm btn-outline-dark" type="button" data-bs-toggle="collapse" data-bs-target="#stokHampirHabisList" aria-expanded="false" aria-controls="stokHampirHabisList">
                            Lihat Detail
                        </button>
                    </div>
                    <div class="collapse mt-3" id="stokHampirHabisList">
                        <hr>
                        <ul class="mb-0 list-group" style="max-height: 250px; overflow-y: auto;">
                            @foreach($stokHampirHabis as $barang)
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    {{ $barang->nama_barang }}
                                    <span class="badge bg-danger rounded-pill">Sisa: {{ $barang->stok }}</span>
                                </li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    @endif

    @if($barangAkanKadaluarsa->isNotEmpty())
        <div class="row mt-4">
            <div class="col-12">
                <div class="alert alert-danger">
                     <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h4 class="alert-heading"><i class="fas fa-calendar-times me-2"></i>Peringatan Barang Akan Kadaluarsa!</h4>
                            <p class="mb-0">Terdapat <strong>{{ $barangAkanKadaluarsa->count() }}</strong> barang yang akan atau sudah kadaluarsa. Segera periksa dan lakukan tindakan.</p>
                        </div>
                        <button class="btn btn-sm btn-outline-dark" type="button" data-bs-toggle="collapse" data-bs-target="#barangKadaluarsaList" aria-expanded="false" aria-controls="barangKadaluarsaList">
                            Lihat Detail
                        </button>
                    </div>
                    <div class="collapse mt-3" id="barangKadaluarsaList">
                        <hr>
                        <ul class="mb-0 list-group" style="max-height: 250px; overflow-y: auto;">
                            @foreach($barangAkanKadaluarsa as $barang)
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    <div>
                                        <strong>{{ $barang->nama_barang }}</strong>
                                        <small class="d-block text-muted">
                                            Kadaluarsa pada: {{ \Carbon\Carbon::parse($barang->tanggal_kadaluarsa)->format('d F Y') }}
                                        </small>
                                    </div>
                                    <span class="badge bg-dark rounded-pill">{{ \Carbon\Carbon::parse($barang->tanggal_kadaluarsa)->diffForHumans() }}</span>
                                </li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    @endif

    <!-- Section Laporan -->
    <div class="row mt-4">
        <div class="col-12">
            <ul class="nav nav-tabs" id="laporanTabs" role="tablist" style="border-bottom: 2px solid #dee2e6;">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="penjualan-tab" data-bs-toggle="tab" data-bs-target="#penjualan" type="button" role="tab" aria-controls="penjualan" aria-selected="true" style="color: #000;">
                        <i class="fas fa-chart-line me-2"></i>Laporan Penjualan
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="inventaris-tab" data-bs-toggle="tab" data-bs-target="#inventaris" type="button" role="tab" aria-controls="inventaris" aria-selected="false" style="color: #000;">
                        <i class="fas fa-boxes me-2"></i>Laporan Inventaris
                    </button>
                </li>
            </ul>

            <style>
                .nav-tabs .nav-link {
                    color: #000 !important;
                }
                .nav-tabs .nav-link:hover {
                    color: #000 !important;
                    border-color: #dee2e6 #dee2e6 #000;
                }
                .nav-tabs .nav-link.active {
                    color: #000 !important;
                    border-color: #dee2e6 #dee2e6 #000;
                }
            </style>

            <div class="tab-content" id="laporanTabsContent">
                <!-- Tab Laporan Penjualan -->
                <div class="tab-pane fade show active" id="penjualan" role="tabpanel" aria-labelledby="penjualan-tab">
                    <br>

                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="shadow-sm">
                                <div class="card-header bg-primary text-white">
                                    <i class="fas fa-chart-line me-2"></i>Grafik Penjualan
                                </div>
                                <div class="card-body">
                                    <div style="height: 400px;">
                                        <canvas id="grafikPenjualan"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="shadow-sm">
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-striped table-hover">
                                            <thead class="table-primary">
                                                <tr>
                                                    <th>No</th>
                                                    <th>Barang</th>
                                                    <th>Jumlah</th>
                                                    <th>Total Harga</th>
                                                    <th>Tanggal</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                @forelse ($transaksis as $index => $transaksi)
                                                    <tr>
                                                        <td>{{ $transaksis->firstItem() + $index }}</td>
                                                        <td>{{ $transaksi->barang->nama_barang ?? '-' }}</td>
                                                        <td>{{ $transaksi->jumlah }}</td>
                                                        <td>Rp {{ number_format($transaksi->total_harga, 0, ',', '.') }}</td>
                                                        <td>{{ $transaksi->created_at->format('d-m-Y H:i') }}</td>
                                                    </tr>
                                                @empty
                                                    <tr>
                                                        <td colspan="5" class="text-center">Tidak ada data transaksi untuk periode ini.</td>
                                                    </tr>
                                                @endforelse
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-4">
                                        <div class="alert alert-success fw-bold mb-0">
                                            Total Penjualan (Sesuai Filter): Rp {{ number_format($total, 0, ',', '.') }}
                                        </div>
                                        <div>
                                            {{ $transaksis->links() }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab Laporan Inventaris -->
                <div class="tab-pane fade" id="inventaris" role="tabpanel" aria-labelledby="inventaris-tab">
                    <div class="mt-3">
                        <h5 class="fw-bold mb-3">Laporan Inventaris Barang</h5>
                        <p class="text-muted">Laporan ini menunjukkan daftar semua barang, stok terkini, dan nilai total inventaris Anda saat ini.</p>

                        <div class="table-responsive">
                            <table class="table table-bordered table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th style="width: 5%;">No</th>
                                        <th>Kode Barang</th>
                                        <th>Nama Barang</th>
                                        <th>Stok Saat Ini</th>
                                        <th>Harga Beli/Satuan</th>
                                        <th>Total Nilai per Barang</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @forelse ($barangs as $index => $barang)
                                        <tr>
                                            <td>{{ $barangs->firstItem() + $index }}</td>
                                            <td>{{ $barang->kode_barang }}</td>
                                            <td>{{ $barang->nama_barang }}</td>
                                            <td>{{ $barang->stok }}</td>
                                            <td>Rp {{ number_format($barang->harga, 0, ',', '.') }}</td>
                                            <td>Rp {{ number_format($barang->stok * $barang->harga, 0, ',', '.') }}</td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="6" class="text-center">Tidak ada data barang di inventaris.</td>
                                        </tr>
                                    @endforelse
                                </tbody>
                                <tfoot class="table-success-subtle">
                                    <tr>
                                        <th colspan="5" class="text-end">Total Nilai Keseluruhan Inventaris:</th>
                                        <th>Rp {{ number_format($totalNilaiInventaris, 0, ',', '.') }}</th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <div class="d-flex justify-content-center mt-4">
                            {{ $barangs->links() }}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
@section('title', 'Dashboard')

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const canvas = document.getElementById('grafikPenjualan');
        if (canvas) {
            const ctx = canvas.getContext('2d');
            const labels = @json($labels);
            const data = @json($data);

            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Total Penjualan',
                        data: data,
                        backgroundColor: 'rgba(74, 144, 226, 0.2)',
                        borderColor: 'rgba(74, 144, 226, 1)',
                        borderWidth: 2,
                        tension: 0.3,
                        fill: true,
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }
    });
</script>
@endpush
