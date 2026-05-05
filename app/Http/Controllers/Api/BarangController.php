<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Barang;
use Illuminate\Http\Request;

class BarangController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = Barang::with('category');

        if ($request->has('search')) {
            $query->where('nama_barang', 'like', '%' . $request->search . '%')
                  ->orWhere('kode_barang', 'like', '%' . $request->search . '%');
        }

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        return response()->json($query->paginate(15));
    }

    /**
     * Get product by barcode
     */
    public function searchByBarcode($kode)
    {
        $barang = Barang::with('category')->where('kode_barang', $kode)->first();
        if (!$barang) {
            return response()->json(['message' => 'Barang tidak ditemukan'], 404);
        }
        return response()->json($barang);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'kode_barang' => 'required|unique:barangs',
            'nama_barang' => 'required',
            'category_id' => 'required|exists:categories,id',
            'stok' => 'required|integer|min:0',
            'minimal_stok' => 'required|integer|min:0',
            'harga' => 'required|numeric|min:0',
            'tanggal_kadaluarsa' => 'nullable|date',
        ]);

        $barang = Barang::create($validated);
        return response()->json($barang, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $barang = Barang::with('category')->findOrFail($id);
        return response()->json($barang);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $barang = Barang::findOrFail($id);

        $validated = $request->validate([
            'kode_barang' => 'required|unique:barangs,kode_barang,' . $id,
            'nama_barang' => 'required',
            'category_id' => 'required|exists:categories,id',
            'stok' => 'required|integer|min:0',
            'minimal_stok' => 'required|integer|min:0',
            'harga' => 'required|numeric|min:0',
            'tanggal_kadaluarsa' => 'nullable|date',
        ]);

        $barang->update($validated);
        return response()->json($barang);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $barang = Barang::findOrFail($id);
        $barang->delete();
        return response()->json(['message' => 'Barang berhasil dihapus']);
    }
}

